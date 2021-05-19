module Cloudflare::Serialized
  module Options
    struct Radar
      struct Quirks
        include YAML::Serializable

        property scanIpAddressType : ScanIpAddressType
        property concurrentCount : Int32
        property numberOfScansPerIpBlock : Int32
        property maximumNumberOfFailuresPerIpBlock : Int32
        property skipRange : Array(Int32)

        def initialize(@scanIpAddressType : ScanIpAddressType = ScanIpAddressType::Ipv4Only)
          @concurrentCount = 220_i32
          @numberOfScansPerIpBlock = 25_i32
          @maximumNumberOfFailuresPerIpBlock = 15_i32
          @skipRange = [3_i32, 6_i32]
        end

        def unwrap : Cloudflare::Options::Radar::Quirks
          check_skip_range!

          quirks = Cloudflare::Options::Radar::Quirks.new
          quirks.scanIpAddressType = scanIpAddressType
          quirks.concurrentCount = concurrentCount
          quirks.numberOfScansPerIpBlock = numberOfScansPerIpBlock
          quirks.maximumNumberOfFailuresPerIpBlock = maximumNumberOfFailuresPerIpBlock
          quirks.skipRange = (skipRange.first..skipRange.last)

          quirks
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
      end
    end
  end
end
