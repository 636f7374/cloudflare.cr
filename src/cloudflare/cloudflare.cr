module Cloudflare
  enum ScanIpAddressType : UInt8
    Ipv4Only = 0_u8
    Ipv6Only = 1_u8
    Both     = 2_u8
  end

  enum ParallelFlag : UInt8
    Distributed = 0_u8
    SubProcess  = 1_u8
    Hybrid      = 2_u8
  end

  enum BindFlag : UInt8
    TCP = 0_u8
    TLS = 1_u8
  end

  def self.unwrap_prefix_24(ip_blocks : Set(IPAddress::IPv4 | IPAddress::IPv6)) : Set(IPAddress::IPv4 | IPAddress::IPv6)
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
