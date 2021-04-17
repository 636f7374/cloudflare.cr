module Cloudflare::Serialized
  module Radar
    struct Callee
      include JSON::Serializable

      property concurrentCount : Int32
      property numberOfScansPerBlock : Int32
      property maximumNumberOfFailuresPerBlock : Int32
      property skipRange : Array(Int32)
      property excludes : Array(Array(Needles::Edge))?
      property timeout : TimeOut
      property ipBlocks : Array(String)

      def initialize
        @concurrentCount = 220_i32
        @numberOfScansPerBlock = 25_i32
        @maximumNumberOfFailuresPerBlock = 15_i32
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
        options = Cloudflare::Options.new
        radar = Cloudflare::Options::Radar.new

        radar.concurrentCount = concurrentCount
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

      struct TimeOut
        include JSON::Serializable

        property read : Int32
        property write : Int32
        property connect : Int32

        def initialize
          @read = 2_i32
          @write = 2_i32
          @connect = 2_i32
        end

        def unwrap : Cloudflare::TimeOut
          timeout = Cloudflare::TimeOut.new

          timeout.read = read
          timeout.write = write
          timeout.connect = connect

          timeout
        end
      end
    end
  end
end
