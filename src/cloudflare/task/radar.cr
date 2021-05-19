module Cloudflare::Task
  struct Radar
    getter ipBlock : IPAddress
    getter caching : Caching::Radar
    getter options : Options

    def initialize(@ipBlock : IPAddress, @caching : Caching::Radar, @options : Options)
    end

    def perform(endpoint : Endpoint) : Bool
      failure_counter = Atomic(UInt64).new 0_u64
      skip_counter = Atomic(UInt64).new 0_u64
      each_counter = Atomic(UInt64).new 0_u64

      ipBlock.each do |ip_address|
        break if failure_counter.get == options.radar.quirks.maximumNumberOfFailuresPerIpBlock
        break if each_counter.get == options.radar.quirks.numberOfScansPerIpBlock
        next skip_counter.sub 1_u64 unless skip_counter.get.zero?

        skip_counter.set options.radar.quirks.skipRange.sample.to_u64
        _ip_address = Socket::IPAddress.new address: ip_address.address, port: endpoint.port.to_i32

        begin
          tuples = Cloudflare::Endpoint.check_radar_establish! ip_address: _ip_address, endpoint: endpoint, options: options

          response, edge, connect_elapsed, establish_elapsed = tuples
          each_counter.add 1_u64
        rescue ex
          failure_counter.add 1_u64

          next
        end

        caching.set ip_block: ipBlock, edge: edge
      end

      true
    end
  end
end
