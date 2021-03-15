module Cloudflare::Serialized
  struct Switcher
    include YAML::Serializable

    property getaddrinfoOverride : Bool

    def initialize(@getaddrinfoOverride : Bool)
    end

    def unwrap : Cloudflare::Options::Switcher
      switcher = Cloudflare::Options::Switcher.new

      switcher.getaddrinfoOverride = getaddrinfoOverride

      switcher
    end
  end
end
