module Cloudflare::Task
  struct Scanner
    getter expect : Expect
    getter caching : Caching::Scanner
    getter options : Options

    def initialize(@expect : Expect, @caching : Caching::Scanner, @options : Options)
    end

    def perform(endpoint : Endpoint) : Bool
      failure_counter = Atomic(UInt64).new 0_u64
      skip_counter = Atomic(UInt64).new 0_u64
      each_counter = Atomic(UInt64).new 0_u64

      expect.ipBlock.each do |ip_address|
        break if failure_counter.get == options.scanner.quirks.maximumNumberOfFailuresPerIpBlock
        break if each_counter.get == options.scanner.quirks.numberOfScansPerIpBlock
        next skip_counter.sub 1_i32 unless skip_counter.get.zero?

        skip_counter.set options.scanner.quirks.skipRange.sample.to_u64
        _ip_address = Socket::IPAddress.new address: ip_address.address, port: endpoint.port.to_i32

        begin
          tuples = Cloudflare::Endpoint.check_radar_establish! ip_address: _ip_address, endpoint: endpoint, options: options

          response, edge, connect_elapsed, establish_elapsed = tuples
          raise Exception.new "Edge.to_iata? is Nil!" unless iata = edge.to_iata?
          next unless entry = expect.entries.find { |expect| iata == expect.iata }

          each_counter.add 1_u64
        rescue ex
          failure_counter.add 1_u64

          next
        end

        caching.set ip_block: expect.ipBlock, iata: iata, priority: entry.priority, ip_address: _ip_address
        sleep options.scanner.quirks.numberOfSleepPerRequest
      end

      true
    end

    struct Expect
      property ipBlock : IPAddress
      property entries : Set(Entry)

      def initialize(@ipBlock : IPAddress, @entries : Set(Entry) = [] of Entry)
      end

      struct Entry
        property iata : Needles::IATA
        property priority : UInt8

        def initialize(@iata : Needles::IATA, @priority : UInt8 = 0_u8)
        end
      end
    end
  end
end
