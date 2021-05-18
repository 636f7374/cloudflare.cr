module Cloudflare::Serialized
  struct Scanner
    include YAML::Serializable

    property endpoint : Endpoint
    property tasks : Array(Entry)
    property caching : Caching
    property quirks : Quirks
    property timeout : TimeOut
    property switcher : Switcher

    def initialize(@endpoint : Endpoint, @tasks : Array(Entry) = [] of Entry, @caching : Caching = Caching.new, @quirks : Quirks = Quirks.new, @timeout : TimeOut = TimeOut.new, @switcher : Switcher = Switcher.new)
    end

    def unwrap : Tuple(Set(Cloudflare::Task::Scanner::Entry), Cloudflare::Scanner)
      unwrapped_tasks = Set(Cloudflare::Task::Scanner::Entry).new

      tasks.each do |task_entry|
        task_entry.ipBlocks.each do |ip_block_text|
          ip_block = IPAddress.new addr: ip_block_text rescue nil
          next unless ip_block

          unwrapped_tasks << Cloudflare::Task::Scanner::Entry.new ipBlock: ip_block, expects: task_entry.get_options_expects
        end
      end

      options_scanner = Cloudflare::Options::Scanner.new

      options_scanner.timeout = timeout.unwrap
      options_scanner.quirks = quirks.unwrap
      options_scanner.caching = caching.unwrap
      options_scanner.switcher = switcher.unwrap

      options = Cloudflare::Options.new
      options.scanner = options_scanner

      Tuple.new unwrapped_tasks, Cloudflare::Scanner.new endpoint: endpoint.unwrap, options: options
    end

    struct Entry
      include YAML::Serializable

      property ipBlocks : Array(String)
      property expects : Array(Expect)
      property excludes : Array(Expect)?

      def initialize(@ipBlocks : Array(String) = [] of String, @expects : Array(Expect) = [] of Expect, @excludes : Array(Expect)? = [] of Expect)
      end

      private def unwrap_expects : Array(Cloudflare::Task::Scanner::Entry::Expect)
        _expects = [] of Cloudflare::Task::Scanner::Entry::Expect

        expects.each do |expect|
          case expect.type
          in .iata?
            next unless iata = Cloudflare::Needles::IATA.parse? expect.name

            _expect = Cloudflare::Task::Scanner::Entry::Expect.new iata: iata, priority: (expect.priority || 10_u8)
            _expects << _expect
          in .edge?
            next unless edge = Cloudflare::Needles::Edge.parse? expect.name
            next unless iata = edge.to_iata?

            _expect = Cloudflare::Task::Scanner::Entry::Expect.new iata: iata, priority: (expect.priority || 10_u8)
            _expects << _expect
          in .region?
            next unless region = Cloudflare::Needles::Region.parse? expect.name

            region.each do |iata|
              _expect = Cloudflare::Task::Scanner::Entry::Expect.new iata: iata, priority: (expect.priority || 10_u8)
              _expects << _expect
            end
          end
        end

        _expects.uniq
      end

      private def unwrap_excludes : Array(Cloudflare::Task::Scanner::Entry::Expect)
        _excludes = [] of Cloudflare::Task::Scanner::Entry::Expect

        excludes.try &.each do |exclude|
          case exclude.type
          in .iata?
            next unless iata = Cloudflare::Needles::IATA.parse? exclude.name

            _exclude = Cloudflare::Task::Scanner::Entry::Expect.new iata: iata, priority: (exclude.priority || 10_u8)
            _excludes << _exclude
          in .edge?
            next unless edge = Cloudflare::Needles::Edge.parse? exclude.name
            next unless iata = edge.to_iata?

            _exclude = Cloudflare::Task::Scanner::Entry::Expect.new iata: iata, priority: (exclude.priority || 10_u8)
            _excludes << _exclude
          in .region?
            next unless region = Cloudflare::Needles::Region.parse? exclude.name

            region.each do |iata|
              _exclude = Cloudflare::Task::Scanner::Entry::Expect.new iata: iata, priority: (exclude.priority || 10_u8)
              _excludes << _exclude
            end
          end
        end

        _excludes.uniq
      end

      def get_options_expects : Array(Cloudflare::Task::Scanner::Entry::Expect)
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

      property ipAddressCapacityPerIpBlock : UInt8
      property clearInterval : UInt8

      def initialize
        @ipAddressCapacityPerIpBlock = 3_u8
        @clearInterval = 30_u8
      end

      def unwrap : Cloudflare::Options::Scanner::Caching
        caching = Cloudflare::Options::Scanner::Caching.new

        caching.ipAddressCapacityPerIpBlock = (0_u8 <= ipAddressCapacityPerIpBlock ? ipAddressCapacityPerIpBlock : 3_u8)
        caching.clearInterval = (0_u8 < clearInterval ? clearInterval : 30_u8).seconds

        caching
      end
    end
  end

  struct Quirks
    include YAML::Serializable

    property numberOfScansPerIpBlock : Int32
    property maximumNumberOfFailuresPerIpBlock : Int32
    property skipRange : Array(Int32)
    property numberOfSleepPerRequest : UInt8
    property numberOfSleepPerRound : UInt8

    def initialize(@numberOfScansPerIpBlock : Int32 = 25_i32, @maximumNumberOfFailuresPerIpBlock : Int32 = 15_i32, @skipRange : Array(Int32) = [3_i32, 6_i32] of Int32, @numberOfSleepPerRequest : UInt8 = 1_u8, @numberOfSleepPerRound : UInt8 = 5_u8)
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

      quirks.numberOfScansPerIpBlock = numberOfScansPerIpBlock
      quirks.maximumNumberOfFailuresPerIpBlock = maximumNumberOfFailuresPerIpBlock
      quirks.skipRange = get_skip_range
      quirks.numberOfSleepPerRequest = numberOfSleepPerRequest.seconds
      quirks.numberOfSleepPerRound = numberOfSleepPerRound.seconds

      quirks
    end
  end

  struct Switcher
    include YAML::Serializable

    property addrinfoOverride : Bool

    def initialize(@addrinfoOverride : Bool = true)
    end

    def unwrap : Cloudflare::Options::Scanner::Switcher
      Cloudflare::Options::Scanner::Switcher.new addrinfoOverride: addrinfoOverride
    end
  end
end
