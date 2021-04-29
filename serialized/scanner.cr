module Cloudflare::Serialized
  struct Scanner
    include YAML::Serializable

    property tasks : Array(Entry)
    property caching : Caching
    property quirks : Quirks
    property timeout : TimeOut
    property switcher : Switcher

    def initialize(@tasks : Array(Task::Block) = [] of Task::Block, @caching : Caching = Caching.new, @quirks : Quirks = Quirks.new, @timeout : TimeOut = TimeOut.new, @switcher : Switcher = Switcher.new)
    end

    def unwrap : Cloudflare::Scanner
      options = Cloudflare::Options.new
      options_scanner = Cloudflare::Options::Scanner.new
      unwrapped_tasks = Set(Cloudflare::Scanner::Task::Entry).new

      tasks.each do |task_entry|
        _ip_block = IPAddress.new task_entry.ipBlock rescue nil
        next unless _ip_block

        unwrapped_tasks << Cloudflare::Scanner::Task::Entry.new ipBlock: _ip_block, expects: task_entry.get_options_expects
      end

      options_scanner.timeout = timeout.unwrap
      options_scanner.quirks = quirks.unwrap
      options_scanner.caching = caching.unwrap

      options.scanner = options_scanner
      options.switcher = switcher.unwrap

      Cloudflare::Scanner.new tasks: unwrapped_tasks, options: options
    end

    struct Entry
      include YAML::Serializable

      property ipBlock : String
      property expects : Array(Expect)
      property excludes : Array(Expect)?

      def initialize(@ipBlock : String = String.new, @expects : Array(Expect) = [] of Expect, @excludes : Array(Expect)? = [] of Expect)
      end

      private def unwrap_expects : Array(Cloudflare::Scanner::Task::Entry::Expect)
        _expects = [] of Cloudflare::Scanner::Task::Entry::Expect

        expects.each do |expect|
          case expect.type
          in .iata?
            next unless iata = Cloudflare::Needles::IATA.parse? expect.name

            _expect = Cloudflare::Scanner::Task::Entry::Expect.new iata: iata, priority: (expect.priority || 10_u8)
            _expects << _expect
          in .edge?
            next unless edge = Cloudflare::Needles::Edge.parse? expect.name
            next unless iata = edge.to_iata?

            _expect = Cloudflare::Scanner::Task::Entry::Expect.new iata: iata, priority: (expect.priority || 10_u8)
            _expects << _expect
          in .region?
            next unless region = Cloudflare::Needles::Region.parse? expect.name

            region.each do |iata|
              _expect = Cloudflare::Scanner::Task::Entry::Expect.new iata: iata, priority: (expect.priority || 10_u8)
              _expects << _expect
            end
          end
        end

        _expects.uniq
      end

      private def unwrap_excludes : Array(Cloudflare::Scanner::Task::Entry::Expect)
        _excludes = [] of Cloudflare::Scanner::Task::Entry::Expect

        excludes.try &.each do |exclude|
          case exclude.type
          in .iata?
            next unless iata = Cloudflare::Needles::IATA.parse? exclude.name

            _exclude = Cloudflare::Scanner::Task::Entry::Expect.new iata: iata, priority: (exclude.priority || 10_u8)
            _excludes << _exclude
          in .edge?
            next unless edge = Cloudflare::Needles::Edge.parse? exclude.name
            next unless iata = edge.to_iata?

            _exclude = Cloudflare::Scanner::Task::Entry::Expect.new iata: iata, priority: (exclude.priority || 10_u8)
            _excludes << _exclude
          in .region?
            next unless region = Cloudflare::Needles::Region.parse? exclude.name

            region.each do |iata|
              _exclude = Cloudflare::Scanner::Task::Entry::Expect.new iata: iata, priority: (exclude.priority || 10_u8)
              _excludes << _exclude
            end
          end
        end

        _excludes.uniq
      end

      def get_options_expects : Array(Cloudflare::Scanner::Task::Entry::Expect)
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

      property ipAddressCapacityPerBlock : UInt8
      property clearInterval : UInt8

      def initialize
        @ipAddressCapacityPerBlock = 3_u8
        @clearInterval = 30_u8
      end

      def unwrap : Cloudflare::Options::Scanner::Caching
        caching = Cloudflare::Options::Scanner::Caching.new

        ip_address_capacity_per_block = ipAddressCapacityPerBlock
        ip_address_capacity_per_block = 1_u8 if 1_u8 > ip_address_capacity_per_block
        caching.ipAddressCapacityPerBlock = ip_address_capacity_per_block

        clear_interval = clearInterval
        clear_interval = 1_u8 if 1_u8 > clear_interval
        caching.clearInterval = clear_interval.seconds

        caching
      end
    end
  end

  struct Quirks
    include YAML::Serializable

    property numberOfScansPerBlock : Int32
    property maximumNumberOfFailuresPerBlock : Int32
    property skipRange : Array(Int32)
    property sleep : UInt8

    def initialize(@numberOfScansPerBlock : Int32 = 25_i32, @maximumNumberOfFailuresPerBlock : Int32 = 15_i32, @skipRange : Array(Int32) = [3_i32, 6_i32] of Int32, @sleep : UInt8 = 1_u8)
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

      quirks.numberOfScansPerBlock = numberOfScansPerBlock
      quirks.maximumNumberOfFailuresPerBlock = maximumNumberOfFailuresPerBlock
      quirks.skipRange = get_skip_range
      quirks.sleep = sleep.seconds

      quirks
    end
  end
end
