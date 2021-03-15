module Cloudflare::Serialized
  struct Switcher
    include YAML::Serializable

    property addrinfoOverride : Bool

    def initialize(@addrinfoOverride : Bool)
    end

    def unwrap : Cloudflare::Options::Switcher
      switcher = Cloudflare::Options::Switcher.new

      switcher.addrinfoOverride = addrinfoOverride

      switcher
    end
  end
end
