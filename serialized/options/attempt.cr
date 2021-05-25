module Cloudflare::Serialized
  module Options
    struct Attempt
      include YAML::Serializable

      property connect : UInt8

      def initialize(@connect : UInt8 = 1_u8)
      end

      def unwrap : Cloudflare::Options::Attempt
        Cloudflare::Options::Attempt.new connect: connect
      end
    end
  end
end
