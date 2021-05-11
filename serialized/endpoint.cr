module Cloudflare::Serialized
  struct Endpoint
    include YAML::Serializable

    property tls : TransportLayerSecurity?
    property port : UInt16
    property method : String
    property path : String
    property parameters : Array(Hash(String, String))?
    property headers : Array(Hash(String, String))?
    property dataRaw : String?

    def initialize(@tls : TransportLayerSecurity?, @port : UInt16, @method : String, @path : String, @parameters : Hash(String, String)?, @headers : Hash(String, String)?, @dataRaw : String?)
    end

    def unwrap : Cloudflare::Endpoint
      case _tls = tls
      in Nil
        bind_type = BindFlag::TCP
      in TransportLayerSecurity
        bind_type = BindFlag::TLS
      end

      _headers = HTTP::Headers.new
      headers.try &.each { |entry| entry.each { |tuple| _headers.add key: tuple.first, value: tuple.last } }
      _parameters = parameters

      resource = String.build do |io|
        io << path

        if _parameters && !_parameters.empty?
          io << '?'
          _parameters.each { |entry| entry.each { |key, value| io << key << '=' << value << '&' } }
        end
      end

      resource = resource[0_i32..-2_i32] if resource.ends_with? '&'

      case bind_type
      in .tcp?
        Cloudflare::Endpoint::TCP.new port: port, method: method, resource: resource, headers: _headers, dataRaw: dataRaw
      in .tls?
        raise Exception.new "Serialized::Radar::Endpoint.unwrap: bindType is TLS, But Endpoint.tls is nil!" unless _tls
        Cloudflare::Endpoint::TLS.new tls: _tls.unwrap, port: port, method: method, resource: resource, headers: _headers, dataRaw: dataRaw
      end
    end
  end
end
