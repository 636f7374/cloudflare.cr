struct Cloudflare::Options
  property radar : Radar
  property scanner : Scanner

  def initialize
    @radar = Radar.new
    @scanner = Scanner.new
  end

  struct Scanner
    property subnets : Array(Subnet)
    property caching : Caching
    property quirks : Quirks
    property timeout : TimeOut

    def initialize(@subnets : Array(Subnet) = [] of Subnet, @caching : Caching = Caching.new, @quirks : Quirks = Quirks.new, @timeout : TimeOut = TimeOut.new)
    end

    struct Subnet
      property ipRange : IPAddress
      property expects : Array(Expect)

      def initialize(@ipRange : IPAddress, @expects : Array(Expect) = [] of Expect)
      end

      struct Expect
        property iata : Needles::IATA
        property priority : UInt8

        def initialize(@iata : Needles::IATA, @priority : UInt8 = 0_u8)
        end
      end
    end

    struct Caching
      property ipAddressCapacityPerSubnet : UInt8
      property clearInterval : Time::Span

      def initialize
        @ipAddressCapacityPerSubnet = 3_u8
        @clearInterval = 30_u8.seconds
      end
    end

    struct Quirks
      property numberOfScansPerSubnet : Int32
      property maximumNumberOfFailuresPerSubnet : Int32
      property skipRange : Range(Int32, Int32)
      property sleep : Time::Span

      def initialize(@numberOfScansPerSubnet : Int32 = 25_i32, @maximumNumberOfFailuresPerSubnet : Int32 = 15_i32, @skipRange : Range(Int32, Int32) = (6_i32..12_i32), @sleep : Time::Span = 1_u8.seconds)
      end
    end
  end

  struct Radar
    enum ScanIpAddressType : UInt8
      Ipv4Only = 0_u8
      Ipv6Only = 1_u8
      Both     = 2_u8
    end

    property concurrentCount : Int32
    property scanIpAddressType : ScanIpAddressType
    property numberOfScansPerSubnet : Int32
    property maximumNumberOfFailuresPerSubnet : Int32
    property skipRange : Range(Int32, Int32)
    property clearIfOnlyNeedles : Set(Set(Needles::Edge))
    property timeout : TimeOut

    def initialize
      @concurrentCount = 220_i32
      @scanIpAddressType = ScanIpAddressType::Ipv4Only
      @numberOfScansPerSubnet = 25_i32
      @maximumNumberOfFailuresPerSubnet = 15_i32
      @skipRange = (6_i32..12_i32)
      @clearIfOnlyNeedles = Set(Set(Needles::Edge)).new
      @timeout = TimeOut.new
    end
  end
end
