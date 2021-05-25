module Cloudflare::Serialized
  struct Scanner
    include YAML::Serializable

    property endpoint : Endpoint
    property tasks : Array(Task)
    property caching : Caching
    property quirks : Quirks
    property dns : DNS
    property timeout : Serialized::Options::TimeOut
    property attempt : Serialized::Options::Attempt

    def initialize(@endpoint : Endpoint, @tasks : Array(Task) = [] of Task, @caching : Caching = Caching.new, @quirks : Quirks = Quirks.new, @dns : DNS = DNS.new, @timeout : Serialized::Options::TimeOut = Serialized::Options::TimeOut.new, @attempt : Serialized::Options::Attempt = Serialized::Options::Attempt.new)
    end

    def unwrap : Tuple(Set(Cloudflare::Task::Scanner::Expect), Cloudflare::Scanner)
      unwrapped_tasks = Set(Cloudflare::Task::Scanner::Expect).new

      tasks.each do |task|
        task.ipBlocks.each do |ip_block_text|
          ip_block = IPAddress.new addr: ip_block_text rescue nil
          next unless ip_block

          unwrapped_tasks << Cloudflare::Task::Scanner::Expect.new ipBlock: ip_block, entries: task.get_excluded_expects
        end
      end

      options_scanner = Cloudflare::Options::Scanner.new

      options_scanner.quirks = quirks.unwrap scanner: self
      options_scanner.caching = caching.unwrap
      options_scanner.timeout = timeout.unwrap
      options_scanner.attempt = attempt.unwrap

      options = Cloudflare::Options.new
      options.scanner = options_scanner

      Tuple.new unwrapped_tasks, Cloudflare::Scanner.new endpoint: endpoint.unwrap, options: options
    end

    struct Task
      include YAML::Serializable

      property ipBlocks : Array(String)
      property expects : Array(Expect)
      property excludes : Array(Expect)?

      def initialize(@ipBlocks : Array(String) = [] of String, @expects : Array(Expect) = [] of Expect, @excludes : Array(Expect)? = [] of Expect)
      end

      {% for name in ["expects", "excludes"] %}
      private def unwrap_{{name.id}} : Array(Cloudflare::Task::Scanner::Expect::Entry)
        _{{name.id}} = [] of Cloudflare::Task::Scanner::Expect::Entry

        {{name.id}}.try &.each do |entry|
          case entry.type
          in .iata?
            next unless iata = Cloudflare::Needles::IATA.parse? entry.name

            _unwrapped_entry = Cloudflare::Task::Scanner::Expect::Entry.new iata: iata, priority: (entry.priority || 10_u8)
            _{{name.id}} << _unwrapped_entry
          in .edge?
            next unless edge = Cloudflare::Needles::Edge.parse? entry.name
            next unless iata = edge.to_iata?

            _unwrapped_entry = Cloudflare::Task::Scanner::Expect::Entry.new iata: iata, priority: (entry.priority || 10_u8)
            _{{name.id}} << _unwrapped_entry
          in .region?
            next unless region = Cloudflare::Needles::Region.parse? entry.name

            region.each do |iata|
              _unwrapped_entry = Cloudflare::Task::Scanner::Expect::Entry.new iata: iata, priority: (entry.priority || 10_u8)
              _{{name.id}} << _unwrapped_entry
            end
          end
        end

        _{{name.id}}.uniq
      end
      {% end %}

      def get_excluded_expects : Set(Cloudflare::Task::Scanner::Expect::Entry)
        _expects = unwrap_expects
        _excludes = unwrap_excludes

        _expects.reject! { |expect| _excludes.any? { |exclude| exclude.iata == expect.iata } }
        _expects.to_set
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

      def unwrap(scanner : Scanner) : Cloudflare::Options::Scanner::Quirks
        quirks = Cloudflare::Options::Scanner::Quirks.new

        quirks.numberOfScansPerIpBlock = numberOfScansPerIpBlock
        quirks.maximumNumberOfFailuresPerIpBlock = maximumNumberOfFailuresPerIpBlock
        quirks.skipRange = get_skip_range
        quirks.numberOfSleepPerRequest = numberOfSleepPerRequest.seconds
        quirks.numberOfSleepPerRound = numberOfSleepPerRound.seconds
        quirks.addrinfoOverride = scanner.dns.addrinfoOverride

        quirks
      end
    end

    struct DNS
      include YAML::Serializable

      property addrinfoOverride : Bool

      def initialize(@addrinfoOverride : Bool = true)
      end

      def unwrap(dns_options : ::DNS::Options) : Nil
        nil
      end
    end
  end
end

require "./options/*"
