abstract struct Cloudflare::Endpoint
  struct TCP < Endpoint
    property port : UInt16
    property method : String
    property resource : String
    property headers : HTTP::Headers
    property dataRaw : String?

    def initialize(@port : UInt16, @method : String, @resource : String, @headers : HTTP::Headers?, @dataRaw : String?)
    end
  end

  struct TLS < Endpoint
    property tls : TransportLayerSecurity
    property port : UInt16
    property method : String
    property resource : String
    property headers : HTTP::Headers
    property dataRaw : String?

    def initialize(@tls : TransportLayerSecurity, @port : UInt16, @method : String, @resource : String, @headers : HTTP::Headers?, @dataRaw : String?)
    end
  end

  {% for function_type in ["radar", "scanner"] %}
  def self.check_{{function_type.id}}_establish!(ip_address : Socket::IPAddress, endpoint : Endpoint, options : Options) : Tuple(HTTP::Client::Response, Cloudflare::Needles::Edge, Time::Span, Time::Span)
    case _endpoint = endpoint
    in Endpoint::TCP
    in Endpoint::TLS
    in Endpoint
      raise Exception.new String.build { |io| io << "Cloudflare::Endpoint.check_" << {{function_type.id.stringify}}  << "_establish!: The endpoint type is not TCP or TLS!" }
    end

    socket, connect_elapsed = Cloudflare.attempt_create_tcp_socket! ip_address: ip_address, attempt_times: options.{{function_type.id}}.attempt.connect, timeout: options.{{function_type.id}}.timeout.tcp
    starting_time = Time.local

    request = HTTP::Request.new method: endpoint.method, resource: endpoint.resource, headers: endpoint.headers, body: endpoint.dataRaw
    request.headers["Host"] = request.headers["Host"]? || String.build { |io| io << ip_address.address << ':' << ip_address.port }
    request.headers["Host"] = request.headers["Host"].gsub "$PORT", endpoint.port

    case _endpoint
    in Endpoint::TCP
      begin
        request.to_io io: socket
        response = HTTP::Client::Response.from_io io: socket, ignore_body: true
      rescue ex
        socket.close rescue nil

        raise ex
      end

      socket.close rescue nil
    in Endpoint::TLS
      tls_socket = Cloudflare.upgrade_tls_socket! socket: socket, tls: _endpoint.tls, timeout: options.{{function_type.id}}.timeout.tls

      begin
        request.to_io io: tls_socket
        response = HTTP::Client::Response.from_io io: tls_socket, ignore_body: true
      rescue ex
        tls_socket.close rescue nil

        raise ex
      end

      tls_socket.close rescue nil
    in Endpoint
      socket.close rescue nil
      raise Exception.new String.build { |io| io << "Cloudflare::Endpoint.check_" << {{function_type.id.stringify}} << "_establish!: The endpoint type is not TCP or TLS!" }
    end

    raise Exception.new String.build { |io| io << "Cloudflare::Endpoint.check_" << {{function_type.id.stringify}} << "_establish!: HTTP::Client::Response.headers[CF-RAY] does not exist." } unless cf_ray = response.headers["CF-RAY"]?
    ray_id, delimiter, iata_text = cf_ray.rpartition '-'
    raise Exception.new String.build { |io| io << "Cloudflare::Endpoint.check_" << {{function_type.id.stringify}} << "_establish!: HTTP::Client::Response.headers[CF-RAY] unknown IATA!" } unless iata = Needles::IATA.parse? iata_text
    raise Exception.new String.build { |io| io << "Cloudflare::Endpoint.check_" << {{function_type.id.stringify}} << "_establish!: HTTP::Client::Response.headers[CF-RAY] IATA.to_edge? is Nil!" } unless edge = iata.to_edge?

    Tuple.new response, edge, connect_elapsed, (Time.local - starting_time)
  end
  {% end %}
end
