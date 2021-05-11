class Cloudflare::Scanner
  struct Task
    getter entry : Entry
    getter caching : Caching::Scanner
    getter options : Options

    def initialize(@entry : Entry, @caching : Caching::Scanner, @options : Options)
    end

    def perform(endpoint : Endpoint) : Bool
      failure_times = Atomic(Int32).new 0_i32
      skip_count = Atomic(Int32).new 0_i32
      each_times = Atomic(Int32).new 0_i32

      entry.ipBlock.each do |ip_address|
        break if failure_times.get == options.scanner.quirks.maximumNumberOfFailuresPerIpBlock
        break if each_times.get == options.scanner.quirks.numberOfScansPerIpBlock
        next skip_count.sub 1_i32 unless skip_count.get.zero?
        skip_count.set options.scanner.quirks.skipRange.sample
        _ip_address = Socket::IPAddress.new address: ip_address.address, port: endpoint.port.to_i32

        begin
          socket = TCPSocket.new ip_address: _ip_address, connect_timeout: options.scanner.timeout.connect
          socket.read_timeout = options.scanner.timeout.read
          socket.write_timeout = options.scanner.timeout.write
        rescue
          failure_times.add 1_i32

          next
        end

        begin
          request = HTTP::Request.new method: endpoint.method, resource: endpoint.resource, headers: endpoint.headers, body: endpoint.dataRaw
          request.headers["Host"] = request.headers["Host"]? || String.build { |io| io << ip_address.address << ':' << endpoint.port }
          request.to_io io: socket

          response = HTTP::Client::Response.from_io io: socket, ignore_body: true
        rescue
          socket.close rescue nil
          failure_times.add 1_i32

          next
        end

        socket.close rescue nil
        next failure_times.add 1_i32 unless value = response.headers["CF-RAY"]?

        ray_id, delimiter, iata_text = value.rpartition '-'
        next failure_times.add 1_i32 unless iata = Needles::IATA.parse? iata_text
        next unless expect = entry.expects.find { |expect| iata == expect.iata }

        each_times.add 1_i32
        socket_ip_address = Socket::IPAddress.new address: ip_address.address, port: 0_i32
        caching.set ip_block: entry.ipBlock, iata: iata, priority: expect.priority, ip_address: socket_ip_address

        sleep options.scanner.quirks.numberOfSleepPerRequest
      end

      true
    end

    struct Entry
      property ipBlock : IPAddress
      property expects : Array(Expect)

      def initialize(@ipBlock : IPAddress, @expects : Array(Expect) = [] of Expect)
      end

      struct Expect
        property iata : Needles::IATA
        property priority : UInt8

        def initialize(@iata : Needles::IATA, @priority : UInt8 = 0_u8)
        end
      end
    end
  end
end
