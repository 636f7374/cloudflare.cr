module Cloudflare::Serialized
  struct TransportLayerSecurity
    include YAML::Serializable

    enum VerifyMode : UInt8
      NONE                 = 0_u8
      PEER                 = 1_u8
      FAIL_IF_NO_PEER_CERT = 2_u8
      CLIENT_ONCE          = 4_u8
    end

    property hostname : String
    property options : Array(String)
    property verifyMode : VerifyMode?

    def initialize(@hostname : String, @options : Array(String), @verifyMode : VerifyMode?)
    end

    def unwrap_options : Set(LibSSL::Options)
      options_set = Set(LibSSL::Options).new

      options.each do |option|
        next unless _option = OpenSSL::SSL::Options.parse? option
        options_set << _option
      end

      options_set
    end

    def unwrap_verify_mode : LibSSL::VerifyMode
      verify_mode = nil
      verifyMode.try { |_verify_mode| verify_mode = LibSSL::VerifyMode.new _verify_mode.value.to_i32 }
      verify_mode || LibSSL::VerifyMode::NONE
    end

    def unwrap : Cloudflare::TransportLayerSecurity
      Cloudflare::TransportLayerSecurity.new hostname: hostname, options: unwrap_options, verifyMode: unwrap_verify_mode
    end
  end
end
