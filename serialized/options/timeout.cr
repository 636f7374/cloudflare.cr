module Cloudflare::Serialized
  module Options
    struct TimeOut
      include YAML::Serializable

      property tcp : Serialized::TimeOut
      property tls : Serialized::TimeOut

      def initialize(@tcp : Serialized::TimeOut = Serialized::TimeOut.new, @tls : Serialized::TimeOut = Serialized::TimeOut.new)
      end

      def unwrap : Cloudflare::Options::TimeOut
        Cloudflare::Options::TimeOut.new tcp: tcp.unwrap, tls: tls.unwrap
      end
    end
  end
end
