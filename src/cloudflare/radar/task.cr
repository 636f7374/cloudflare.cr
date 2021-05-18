class Cloudflare::Radar
  struct Task
    getter ipBlock : IPAddress
    getter storage : Storage
    getter options : Options

    def initialize(@ipBlock : IPAddress, @storage : Storage, @options : Options)
    end

    def perform(endpoint : Endpoint) : Bool
      failure_times = Atomic(Int32).new 0_i32
      skip_count = Atomic(Int32).new 0_i32
      each_times = Atomic(Int32).new 0_i32

      ipBlock.each do |ip_address|
        break if failure_times.get == options.radar.maximumNumberOfFailuresPerIpBlock
        break if each_times.get == options.radar.numberOfScansPerIpBlock
        next skip_count.sub 1_i32 unless skip_count.get.zero?
        skip_count.set options.radar.skipRange.sample
        _ip_address = Socket::IPAddress.new address: ip_address.address, port: endpoint.port.to_i32

        begin
          socket = TCPSocket.new ip_address: _ip_address, connect_timeout: options.radar.timeout.connect
          socket.read_timeout = options.radar.timeout.read
          socket.write_timeout = options.radar.timeout.write
        rescue
          failure_times.add 1_i32

          next
        end

        begin
          request = HTTP::Request.new method: endpoint.method, resource: endpoint.resource, headers: endpoint.headers, body: endpoint.dataRaw
          request.headers["Host"] = request.headers["Host"]? || String.build { |io| io << ip_address.address << ':' << endpoint.port }
          request.headers["Host"] = request.headers["Host"].gsub "$PORT", endpoint.port
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
        next failure_times.add 1_i32 unless edge = iata.to_edge?

        each_times.add 1_i32
        storage.set ip_block: ipBlock, edge: edge
      end

      true
    end
  end
end
