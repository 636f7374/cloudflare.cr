struct Cloudflare::Options
  property switcher : Switcher
  property radar : Radar
  property scanner : Scanner

  def initialize
    @radar = Radar.new
    @scanner = Scanner.new
    @switcher = Switcher.new
  end

  struct Switcher
    property addrinfoOverride : Bool

    def initialize(@addrinfoOverride : Bool = true)
    end
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
    property excludes : Set(Set(Needles::Edge))
    property timeout : TimeOut

    def initialize
      @concurrentCount = 220_i32
      @scanIpAddressType = ScanIpAddressType::Ipv4Only
      @numberOfScansPerSubnet = 25_i32
      @maximumNumberOfFailuresPerSubnet = 15_i32
      @skipRange = (6_i32..12_i32)
      @excludes = Set(Set(Needles::Edge)).new
      @timeout = TimeOut.new
    end

    def get_subnets : Set(IPAddress::IPv4 | IPAddress::IPv6)
      case scanIpAddressType
      in .ipv4_only?
        Cloudflare::Subnet::Ipv4
      in .ipv6_only?
        Cloudflare::Subnet::Ipv6
      in .both?
        list = Set(Set(IPAddress::IPv4 | IPAddress::IPv6)).new
        list << Cloudflare::Subnet::Ipv4
        list << Cloudflare::Subnet::Ipv6

        list.map(&.to_a).flatten.to_set
      end
    end

    def get_prefix_24_subnets : Set(IPAddress::IPv4 | IPAddress::IPv6)
      to_prefix_24 subnets: get_subnets
    end

    private def to_prefix_24(subnets : Set(IPAddress::IPv4 | IPAddress::IPv6)) : Set(IPAddress::IPv4 | IPAddress::IPv6)
      concurrent_mutex = Mutex.new :unchecked
      concurrent_fibers = Set(Fiber).new
      list_mutex = Mutex.new :unchecked
      list = Set(IPAddress::IPv4 | IPAddress::IPv6).new

      main_concurrent_fiber = spawn do
        subnets.each do |subnet|
          task_fiber = spawn do
            if (subnet.prefix < 24_i32) && subnet.is_a?(IPAddress::IPv4)
              subnet.subnets(24_i32).each do |prefix_24_subnet|
                list_mutex.synchronize { list << prefix_24_subnet }
              end

              next
            end

            list_mutex.synchronize { list << subnet }
          end

          concurrent_mutex.synchronize { concurrent_fibers << task_fiber }
          sleep 0.01_f32.seconds
        end
      end

      concurrent_mutex.synchronize { concurrent_fibers << main_concurrent_fiber }

      loop do
        all_dead = concurrent_mutex.synchronize { concurrent_fibers.all? { |fiber| fiber.dead? } }
        next sleep 0.25_f32.seconds unless all_dead

        break list
      end
    end
  end
end
