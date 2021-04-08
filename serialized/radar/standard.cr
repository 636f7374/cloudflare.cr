module Cloudflare::Serialized
  module Radar
    struct Standard
      include YAML::Serializable

      enum ParallelFlag : UInt8
        Distributed = 0_u8
        SubProcess  = 1_u8
        Hybrid      = 2_u8
      end

      property parallel : Parallel?
      property concurrentCount : Int32
      property scanIpAddressType : Cloudflare::Options::Radar::ScanIpAddressType
      property numberOfScansPerBlock : Int32
      property maximumNumberOfFailuresPerBlock : Int32
      property skipRange : Array(Int32)
      property excludes : Array(Array(Needles::Edge))?
      property timeout : TimeOut
      property outputPath : String?

      def initialize
        @parallel = nil
        @concurrentCount = 220_i32
        @scanIpAddressType = Cloudflare::Options::Radar::ScanIpAddressType::Ipv4Only
        @numberOfScansPerBlock = 25_i32
        @maximumNumberOfFailuresPerBlock = 15_i32
        @skipRange = [3_i32, 6_i32]
        @excludes = [[Needles::Edge::LosAngeles_UnitedStates], [Needles::Edge::SanJose_UnitedStates], [
          Needles::Edge::LosAngeles_UnitedStates, Needles::Edge::SanJose_UnitedStates,
        ]]
        @timeout = TimeOut.new
        @outputPath = nil
      end

      def get_output_path!
        abort "Error: Standard.outputPath is Nil!" unless output_path = outputPath
        output_path.gsub "$HOME", (ENV["HOME"]? || String.new)
      end

      private def check_skip_range!
        if 2_i32 != skipRange.size
          raise Exception.new "Unfortunately, skipRange must be an array containing two Int32."
        end

        if 0_i32 > skipRange.first
          raise Exception.new "Unfortunately, the first Int32 of skipRange must be greater than negative one."
        end

        if skipRange.last < skipRange.first
          raise Exception.new "Unfortunately, the second Int32 of skipRange must be greater than the first Int32."
        end
      end

      def unwrap : Cloudflare::Radar
        options = Cloudflare::Options.new
        radar = Cloudflare::Options::Radar.new

        radar.concurrentCount = concurrentCount
        radar.scanIpAddressType = scanIpAddressType
        radar.numberOfScansPerBlock = numberOfScansPerBlock
        radar.maximumNumberOfFailuresPerBlock = maximumNumberOfFailuresPerBlock
        radar.timeout = timeout.unwrap

        check_skip_range!
        radar.skipRange = (skipRange.first..skipRange.last)

        if _excludes = excludes
          radar.excludes = _excludes.map(&.to_set).to_set
        end

        options.radar = radar

        Cloudflare::Radar.new options: options
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
