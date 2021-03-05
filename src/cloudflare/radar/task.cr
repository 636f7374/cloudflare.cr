class Cloudflare::Radar
  struct Task
    getter ipRange : IPAddress
    getter storage : Storage
    getter options : Options

    def initialize(@ipRange : IPAddress, @storage : Storage, @options : Options)
    end

    def perform(method : String = "HEAD", port : Int32 = 80_i32) : Bool
      failure_times = 0_i32
      skip_count = 0_i32
      each_times = 0_i32

      ipRange.each do |ip_address|
        break if failure_times == options.radar.maximumNumberOfFailuresPerSubnet
        break if each_times == options.radar.numberOfScansPerSubnet
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
        storage.set ip_range: ipRange, edge: edge
      end

      true
    end
  end
end
