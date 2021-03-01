module Cloudflare::Serialization
  struct Scanner
    include YAML::Serializable

    property subnets : Array(Subnet)
    property caching : Caching
    property quirks : Quirks
    property timeout : TimeOut

    def initialize(@subnets : Array(Subnet) = [] of Subnet, @caching : Caching = Caching.new, @quirks : Quirks = Quirks.new, @timeout : TimeOut = TimeOut.new)
    end

    def unwrap : Cloudflare::Scanner
      options = Cloudflare::Options.new
      options_scanner = Cloudflare::Options::Scanner.new

      subnets.each do |subnet|
        _ip_range = IPAddress.new subnet.ipRange rescue nil
        next unless _ip_range

        subnet = Cloudflare::Options::Scanner::Subnet.new ipRange: _ip_range, expects: subnet.get_options_expects
        options_scanner.subnets << subnet
      end

      options_scanner.timeout = timeout.unwrap
      options_scanner.quirks = quirks.unwrap
      options_scanner.caching = caching.unwrap
      options.scanner = options_scanner

      Cloudflare::Scanner.new options: options
    end

    struct Subnet
      include YAML::Serializable

      property ipRange : String
      property expects : Array(Expect)
      property excludes : Array(Expect)?

      def initialize(@ipRange : String = String.new, @expects : Array(Expect) = [] of Expect, @excludes : Array(Expect)? = [] of Expect)
      end

      private def unwrap_expects : Array(Cloudflare::Options::Scanner::Subnet::Expect)
        _expects = [] of Cloudflare::Options::Scanner::Subnet::Expect

        expects.each do |expect|
          case expect.type
          in .iata?
            next unless iata = Cloudflare::Needles::IATA.parse? expect.name

            _expect = Cloudflare::Options::Scanner::Subnet::Expect.new iata: iata, priority: (expect.priority || 10_u8)
            _expects << _expect
          in .edge?
            next unless edge = Cloudflare::Needles::Edge.parse? expect.name
            next unless iata = edge.to_iata?

            _expect = Cloudflare::Options::Scanner::Subnet::Expect.new iata: iata, priority: (expect.priority || 10_u8)
            _expects << _expect
          in .region?
            next unless region = Cloudflare::Needles::Region.parse? expect.name

            region.each do |iata|
              _expect = Cloudflare::Options::Scanner::Subnet::Expect.new iata: iata, priority: (expect.priority || 10_u8)
              _expects << _expect
            end
          end
        end

        _expects.uniq
      end

      private def unwrap_excludes : Array(Cloudflare::Options::Scanner::Subnet::Expect)
        _excludes = [] of Cloudflare::Options::Scanner::Subnet::Expect

        excludes.try &.each do |exclude|
          case exclude.type
          in .iata?
            next unless iata = Cloudflare::Needles::IATA.parse? exclude.name

            _exclude = Cloudflare::Options::Scanner::Subnet::Expect.new iata: iata, priority: (exclude.priority || 10_u8)
            _excludes << _exclude
          in .edge?
            next unless edge = Cloudflare::Needles::Edge.parse? exclude.name
            next unless iata = edge.to_iata?

            _exclude = Cloudflare::Options::Scanner::Subnet::Expect.new iata: iata, priority: (exclude.priority || 10_u8)
            _excludes << _exclude
          in .region?
            next unless region = Cloudflare::Needles::Region.parse? exclude.name

            region.each do |iata|
              _exclude = Cloudflare::Options::Scanner::Subnet::Expect.new iata: iata, priority: (exclude.priority || 10_u8)
              _excludes << _exclude
            end
          end
        end

        _excludes.uniq
      end

      def get_options_expects : Array(Cloudflare::Options::Scanner::Subnet::Expect)
        _expects = unwrap_expects
        _excludes = unwrap_excludes

        _expects.reject! { |expect| _excludes.each { |exclude| break true if exclude.iata == expect.iata } }
        _expects
      end

      struct Expect
        include YAML::Serializable

        property name : String
        property priority : UInt8?
        property type : Cloudflare::Needles::Flag

        def initialize(@name : String = String.new, @priority : UInt8? = 10_u8, @type : Cloudflare::Needles::Flag = Cloudflare::Needles::Flag::IATA)
        end
      end
    end

    struct Caching
      include YAML::Serializable

      property ipAddressCapacityPerSubnet : UInt8
      property clearInterval : UInt8

      def initialize
        @ipAddressCapacityPerSubnet = 3_u8
        @clearInterval = 30_u8
      end

      def unwrap : Cloudflare::Options::Scanner::Caching
        caching = Cloudflare::Options::Scanner::Caching.new

        ip_address_capacity_per_subnet = ipAddressCapacityPerSubnet
        ip_address_capacity_per_subnet = 1_u8 if 1_u8 > ip_address_capacity_per_subnet
        caching.ipAddressCapacityPerSubnet = ip_address_capacity_per_subnet

        clear_interval = clearInterval
        clear_interval = 1_u8 if 1_u8 > clear_interval
        caching.clearInterval = clear_interval.seconds

        caching
      end
    end
  end

  struct Quirks
    include YAML::Serializable

    property numberOfScansPerSubnet : Int32
    property maximumNumberOfFailuresPerSubnet : Int32
    property skipRange : Array(Int32)
    property sleep : UInt8

    def initialize(@numberOfScansPerSubnet : Int32 = 25_i32, @maximumNumberOfFailuresPerSubnet : Int32 = 15_i32, @skipRange : Array(Int32) = [3_i32, 6_i32] of Int32, @sleep : UInt8 = 1_u8)
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

    private def get_skip_range : Range(Int32, Int32)
      begin
        check_skip_range!
        (skipRange.first..skipRange.last)
      rescue ex
        (3_i32..6_i32)
      end
    end

    def unwrap : Cloudflare::Options::Scanner::Quirks
      quirks = Cloudflare::Options::Scanner::Quirks.new

      quirks.numberOfScansPerSubnet = numberOfScansPerSubnet
      quirks.maximumNumberOfFailuresPerSubnet = maximumNumberOfFailuresPerSubnet
      quirks.skipRange = get_skip_range
      quirks.sleep = sleep.seconds

      quirks
    end
  end

  struct TimeOut
    include YAML::Serializable

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
