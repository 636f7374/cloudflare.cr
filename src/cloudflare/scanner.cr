class Cloudflare::Scanner
  getter options : Options
  getter caching : Caching::Scanner
  getter terminated : Bool
  getter running : Bool
  getter mutex : Mutex

  def initialize(@options : Options, @caching : Caching::Scanner)
    @terminated = false
    @running = false
    @mutex = Mutex.new :unchecked
  end

  def self.new(options : Options)
    caching = Cloudflare::Caching::Scanner.new options: options
    new options: options, caching: caching
  end

  def caching_to_tuple_ip_addresses : Array(Tuple(Needles::IATA, Socket::IPAddress))
    caching.to_tuple_ip_addresses
  end

  def terminate
    @mutex.synchronize do
      @running = false
      @terminated = true
    end
  end

  def perform
    raise Exception.new "Scanner.perform: Scanner is already running!" if running
    raise Exception.new "Scanner.perform: Scanner has terminated!" if terminated
    @mutex.synchronize { @running = true }

    loop do
      concurrent_mutex = Mutex.new :unchecked
      concurrent_fibers = Set(Fiber).new

      options.scanner.subnets.each do |subnet|
        task_fiber = spawn do
          task = Task.new subnet: subnet, caching: caching, options: options
          task.perform
        end

        concurrent_mutex.synchronize { concurrent_fibers << task_fiber }
      end

      loop do
        all_dead = concurrent_mutex.synchronize { concurrent_fibers.all? { |fiber| fiber.dead? } }
        next sleep 0.25_f32.seconds unless all_dead

        break
      end

      if terminated
        @mutex.synchronize { @running = false }

        break
      end
    end
  end
end

require "./caching/*"
require "./scanner/*"
