struct Cloudflare::Options
  property switcher : Switcher
  property radar : Radar
  property scanner : Scanner

  def initialize(@radar : Radar = Radar.new, @scanner : Scanner = Scanner.new, @switcher : Switcher = Switcher.new)
  end

  struct Switcher
    property addrinfoOverride : Bool

    def initialize(@addrinfoOverride : Bool = true)
    end
  end

  struct Scanner
    property caching : Caching
    property quirks : Quirks
    property timeout : TimeOut

    def initialize(@caching : Caching = Caching.new, @quirks : Quirks = Quirks.new, @timeout : TimeOut = TimeOut.new)
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

      def initialize(@numberOfScansPerIpBlock : Int32 = 25_i32, @maximumNumberOfFailuresPerIpBlock : Int32 = 15_i32, @skipRange : Range(Int32, Int32) = (6_i32..12_i32),
                     @numberOfSleepPerRequest : Time::Span = 1_u8.seconds, @numberOfSleepPerRound : Time::Span = 5_u8.seconds)
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
    property numberOfScansPerIpBlock : Int32
    property maximumNumberOfFailuresPerIpBlock : Int32
    property skipRange : Range(Int32, Int32)
    property excludes : Set(Set(Needles::Edge))
    property timeout : TimeOut

    def initialize
      @concurrentCount = 220_i32
      @scanIpAddressType = ScanIpAddressType::Ipv4Only
      @numberOfScansPerIpBlock = 25_i32
      @maximumNumberOfFailuresPerIpBlock = 15_i32
      @skipRange = (6_i32..12_i32)
      @excludes = Set(Set(Needles::Edge)).new
      @timeout = TimeOut.new
    end

    def get_ip_blocks : Set(IPAddress::IPv4 | IPAddress::IPv6)
      case scanIpAddressType
      in .ipv4_only?
        Cloudflare::IpBlock::Ipv4
      in .ipv6_only?
        Cloudflare::IpBlock::Ipv6
      in .both?
        list = Set(Set(IPAddress::IPv4 | IPAddress::IPv6)).new
        list << Cloudflare::IpBlock::Ipv4
        list << Cloudflare::IpBlock::Ipv6

        list.map(&.to_a).flatten.to_set
      end
    end

    def get_prefix_24_ip_blocks : Set(IPAddress::IPv4 | IPAddress::IPv6)
      to_prefix_24 ip_blocks: get_ip_blocks
    end

    private def to_prefix_24(ip_blocks : Set(IPAddress::IPv4 | IPAddress::IPv6)) : Set(IPAddress::IPv4 | IPAddress::IPv6)
      concurrent_mutex = Mutex.new :unchecked
      concurrent_fibers = Set(Fiber).new
      list_mutex = Mutex.new :unchecked
      list = Set(IPAddress::IPv4 | IPAddress::IPv6).new

      main_concurrent_fiber = spawn do
        ip_blocks.each do |ip_block|
          next list_mutex.synchronize { list << ip_block } if 24_i32 <= ip_block.prefix.to_i

          task_fiber = spawn do
            if ip_block.is_a? IPAddress::IPv4
              ip_block.subnets(24_i32).each do |prefix_24_block|
                list_mutex.synchronize { list << prefix_24_block }
              end

              next
            end

            list_mutex.synchronize { list << ip_block }
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
