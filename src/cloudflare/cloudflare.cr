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

  enum ScannerControllerFlag : UInt8
    FETCH = 0_u8
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

  def self.attempt_create_tcp_socket!(ip_address : Socket::IPAddress, attempt_times : UInt8, timeout : TimeOut) : Tuple(TCPSocket, Time::Span)
    starting_time = Time.local

    attempt_times.times do |time|
      begin
        socket = TCPSocket.new ip_address: ip_address, connect_timeout: timeout.connect
        socket.read_timeout = timeout.read
        socket.write_timeout = timeout.write

        next if socket.closed?
        socket.remote_address

        return Tuple.new socket, (Time.local - starting_time)
      rescue ex : IO::Error
        next if "Error reading socket: Connection reset by peer" == ex.message

        raise ex
      rescue ex
        raise ex
      end
    end

    raise Exception.new String.build { |io| io << "Cloudflare.attempt_create_tcp_socket!: " << "After " << attempt_times << " attempts to connect (" << ip_address << "), It still fails!" }
  end

  def self.upgrade_tls_socket!(socket : TCPSocket, tls : TransportLayerSecurity, timeout : TimeOut) : Tuple(OpenSSL::SSL::Context::Client, OpenSSL::SSL::Socket::Client)
    begin
      tls_context = tls.unwrap
    rescue ex
      socket.close rescue nil

      raise ex
    end

    socket.read_timeout = timeout.read
    socket.write_timeout = timeout.write

    begin
      tls_socket = OpenSSL::SSL::Socket::Client.new io: socket, context: tls_context, sync_close: true, hostname: (tls.hostname.empty? ? nil : tls.hostname)
      tls_socket.sync = true
    rescue ex
      socket.close rescue nil

      tls_context.skip_finalize = true
      tls_context.free

      raise ex
    end

    Tuple.new tls_context, tls_socket
  end
end
