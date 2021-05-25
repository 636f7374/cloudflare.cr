module Cloudflare::Serialized
  module Radar
    struct Standard
      include YAML::Serializable

      property endpoint : Endpoint
      property parallel : Parallel?
      property excludes : Array(Array(Needles::Edge))?
      property quirks : Serialized::Options::Radar::Quirks
      property timeout : Serialized::Options::TimeOut
      property attempt : Serialized::Options::Attempt
      property outputPath : String?

      def initialize(@endpoint : Endpoint)
        @parallel = nil
        @excludes = [[Needles::Edge::LosAngeles_UnitedStates], [Needles::Edge::SanJose_UnitedStates], [
          Needles::Edge::LosAngeles_UnitedStates, Needles::Edge::SanJose_UnitedStates,
        ]]
        @quirks = Serialized::Options::Radar::Quirks.new
        @timeout = Serialized::Options::TimeOut.new
        @attempt = Serialized::Options::Attempt.new
        @outputPath = nil
      end

      def get_output_path!
        abort "Error: Standard.outputPath is Nil!" unless output_path = outputPath
        output_path.gsub "$HOME", (ENV["HOME"]? || String.new)
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

      struct Parallel
        include YAML::Serializable

        property executableName : String
        property calleeCount : Int32
        property subProcessCalleeCount : Int32?
        property listenAddress : String
        property type : ParallelFlag

        def initialize(@executableName : String, @calleeCount : Int32, @subProcessCalleeCount : Int32?, @listenAddress : String, @type : ParallelFlag)
        end

        def get_listen_address! : Socket::Address
          Socket::Address.parse listenAddress
        end
      end
    end
  end
end
