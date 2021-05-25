struct Cloudflare::Options
  property radar : Radar
  property scanner : Scanner

  def initialize(@radar : Radar = Radar.new, @scanner : Scanner = Scanner.new)
  end

  struct Scanner
    property caching : Caching
    property quirks : Quirks
    property timeout : TimeOut
    property attempt : Attempt

    def initialize(@caching : Caching = Caching.new, @quirks : Quirks = Quirks.new, @timeout : TimeOut = TimeOut.new, @attempt : Attempt = Attempt.new)
    end

    struct Caching
      property ipAddressCapacityPerIpBlock : UInt8
      property clearInterval : Time::Span

      def initialize
        @ipAddressCapacityPerIpBlock = 3_u8
        @clearInterval = 30_u8.seconds
      end
    end

    struct Quirks
      property numberOfScansPerIpBlock : Int32
      property maximumNumberOfFailuresPerIpBlock : Int32
      property skipRange : Range(Int32, Int32)
      property numberOfSleepPerRequest : Time::Span
      property numberOfSleepPerRound : Time::Span
      property addrinfoOverride : Bool

      def initialize(@numberOfScansPerIpBlock : Int32 = 25_i32, @maximumNumberOfFailuresPerIpBlock : Int32 = 15_i32, @skipRange : Range(Int32, Int32) = (6_i32..12_i32),
                     @numberOfSleepPerRequest : Time::Span = 1_u8.seconds, @numberOfSleepPerRound : Time::Span = 5_u8.seconds, @addrinfoOverride : Bool = true)
      end
    end
  end

  struct Radar
    property quirks : Quirks
    property excludes : Set(Set(Needles::Edge))
    property timeout : TimeOut
    property attempt : Attempt

    def initialize(@quirks : Quirks = Quirks.new, @excludes = Set(Set(Needles::Edge)).new, @timeout = TimeOut.new, @attempt : Attempt = Attempt.new)
    end

    def get_ip_blocks : Set(IPAddress::IPv4 | IPAddress::IPv6)
      case quirks.scanIpAddressType
      in .ipv4_only?
        IpBlock::Ipv4
      in .ipv6_only?
        IpBlock::Ipv6
      in .both?
        list = Set(Set(IPAddress::IPv4 | IPAddress::IPv6)).new
        list << IpBlock::Ipv4
        list << IpBlock::Ipv6

        list.map(&.to_a).flatten.to_set
      end
    end

    def get_prefix_24_ip_blocks : Set(IPAddress::IPv4 | IPAddress::IPv6)
      Cloudflare.unwrap_prefix_24 ip_blocks: get_ip_blocks
    end

    struct Quirks
      property scanIpAddressType : ScanIpAddressType
      property concurrentCount : Int32
      property numberOfScansPerIpBlock : Int32
      property maximumNumberOfFailuresPerIpBlock : Int32
      property skipRange : Range(Int32, Int32)

      def initialize(@scanIpAddressType : ScanIpAddressType = ScanIpAddressType::Ipv4Only)
        @concurrentCount = 220_i32
        @numberOfScansPerIpBlock = 25_i32
        @maximumNumberOfFailuresPerIpBlock = 15_i32
        @skipRange = (3_i32..6_i32)
      end
    end
  end

  struct TimeOut
    property tcp : Cloudflare::TimeOut
    property tls : Cloudflare::TimeOut

    def initialize(@tcp : Cloudflare::TimeOut = Cloudflare::TimeOut.new, @tls : Cloudflare::TimeOut = Cloudflare::TimeOut.new)
    end
  end

  struct Attempt
    property connect : UInt8

    def initialize(@connect : UInt8 = 1_u8)
    end
  end
end
