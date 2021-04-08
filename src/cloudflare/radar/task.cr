class Cloudflare::Radar
  struct Task
    getter block : IPAddress
    getter storage : Storage
    getter options : Options

    def initialize(@block : IPAddress, @storage : Storage, @options : Options)
    end

    def perform(method : String = "HEAD", port : Int32 = 80_i32) : Bool
      failure_times = 0_i32
      skip_count = 0_i32
      each_times = 0_i32

      block.each do |ip_address|
        break if failure_times == options.radar.maximumNumberOfFailuresPerBlock
        break if each_times == options.radar.numberOfScansPerBlock
        next skip_count -= 1_i32 unless skip_count.zero?
        skip_count = options.radar.skipRange.sample
        _ip_address = Socket::IPAddress.new address: ip_address.address, port: port

        begin
          socket = TCPSocket.new ip_address: _ip_address, connect_timeout: options.radar.timeout.connect
          socket.read_timeout = options.radar.timeout.read
          socket.write_timeout = options.radar.timeout.write
        rescue
          next failure_times += 1_i32
        end

        begin
          http_request = HTTP::Request.new method: method, resource: "/"
          http_request.headers["Host"] = String.build { |io| io << ip_address.address << ":" << port }
          http_request.to_io socket
          http_response = HTTP::Client::Response.from_io socket
        rescue
          socket.close rescue nil
          next failure_times += 1_i32
        end

        socket.close rescue nil
        next failure_times += 1_i32 unless value = http_response.headers["CF-RAY"]?
        ray_id, delimiter, text_iata = value.rpartition "-"
        next failure_times += 1_i32 unless iata = Needles::IATA.parse? text_iata
        next failure_times += 1_i32 unless edge = iata.to_edge?

        each_times += 1_i32
        storage.set block: block, edge: edge
      end

      true
    end
  end
end
