module Cloudflare::Serialized
  module Radar
    struct Callee
      include YAML::Serializable

      property concurrentCount : Int32
      property numberOfScansPerIpBlock : Int32
      property maximumNumberOfFailuresPerIpBlock : Int32
      property skipRange : Array(Int32)
      property excludes : Array(Array(Needles::Edge))?
      property timeout : TimeOut
      property ipBlocks : Array(String)

      def initialize
        @concurrentCount = 220_i32
        @numberOfScansPerIpBlock = 25_i32
        @maximumNumberOfFailuresPerIpBlock = 15_i32
        @skipRange = [3_i32, 6_i32]
        @excludes = [[Needles::Edge::LosAngeles_UnitedStates], [Needles::Edge::SanJose_UnitedStates], [
          Needles::Edge::LosAngeles_UnitedStates, Needles::Edge::SanJose_UnitedStates,
        ]]
        @timeout = TimeOut.new
        @ipBlocks = [] of String
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
        check_skip_range!

        radar = Cloudflare::Options::Radar.new
        radar.concurrentCount = concurrentCount
        radar.numberOfScansPerIpBlock = numberOfScansPerIpBlock
        radar.maximumNumberOfFailuresPerIpBlock = maximumNumberOfFailuresPerIpBlock
        radar.timeout = timeout.unwrap
        radar.skipRange = (skipRange.first..skipRange.last)

        if _excludes = excludes
          radar.excludes = _excludes.map(&.to_set).to_set
        end

        options = Cloudflare::Options.new
        options.radar = radar

        Cloudflare::Radar.new options: options
      end
    end
  end
end
