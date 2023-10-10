module Cloudflare::Serialized
  module Radar
    struct Callee
      include YAML::Serializable

      property endpoint : Endpoint
      property excludes : Array(Array(Needles::Edge))?
      property quirks : Serialized::Options::Radar::Quirks
      property timeout : Serialized::Options::TimeOut
      property attempt : Serialized::Options::Attempt
      property ipBlocks : Array(String)

      def initialize(@endpoint : Endpoint)
        @excludes = [[Needles::Edge::LosAngeles_CA_UnitedStates], [Needles::Edge::SanJose_CA_UnitedStates], [
          Needles::Edge::LosAngeles_CA_UnitedStates, Needles::Edge::SanJose_CA_UnitedStates,
        ]]
        @quirks = Serialized::Options::Radar::Quirks.new
        @timeout = Serialized::Options::TimeOut.new
        @attempt = Serialized::Options::Attempt.new
        @ipBlocks = [] of String
      end

      def unwrap : Cloudflare::Radar
        radar = Cloudflare::Options::Radar.new
        radar.quirks = quirks.unwrap
        radar.timeout = timeout.unwrap
        radar.attempt = attempt.unwrap

        _excludes = excludes
        radar.excludes = _excludes.map(&.to_set).to_set if _excludes

        options = Cloudflare::Options.new radar: radar

        Cloudflare::Radar.new endpoint: endpoint.unwrap, options: options
      end
    end
  end
end
