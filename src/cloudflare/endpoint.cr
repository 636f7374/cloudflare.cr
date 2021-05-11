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
end
