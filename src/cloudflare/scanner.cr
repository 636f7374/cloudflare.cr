class Cloudflare::Scanner
  getter blocks : Array(Task::Block)
  getter options : Options
  getter caching : Caching::Scanner
  getter terminated : Bool
  getter running : Bool
  getter mutex : Mutex

  def initialize(@blocks : Array(Task::Block), @options : Options, @caching : Caching::Scanner)
    @terminated = false
    @running = false
    @mutex = Mutex.new :unchecked
  end

  def self.new(blocks : Array(Task::Block), options : Options)
    caching = Cloudflare::Caching::Scanner.new options: options
    new blocks: blocks, options: options, caching: caching
  end

  def caching_to_tuple_ip_addresses : Array(Tuple(Needles::IATA, Socket::IPAddress))
    caching.to_tuple_ip_addresses
  end

  def terminate
    @mutex.synchronize { @terminated = true }
  end

  def perform
    raise Exception.new "Scanner.perform: Scanner is already running!" if @mutex.synchronize { running }
    raise Exception.new "Scanner.perform: Scanner has terminated!" if @mutex.synchronize { terminated }
    @mutex.synchronize { @running = true }

    loop do
      concurrent_mutex = Mutex.new :unchecked
      concurrent_fibers = Set(Fiber).new
      _terminated = false

      blocks.each do |block|
        task_fiber = spawn do
          task = Task.new block: block, caching: caching, options: options
          task.perform
        end

        concurrent_mutex.synchronize { concurrent_fibers << task_fiber }
      end

      loop do
        _terminated = @mutex.synchronize { terminated }
        break @mutex.synchronize { @running = false } if _terminated

        all_dead = concurrent_mutex.synchronize { concurrent_fibers.all? { |fiber| fiber.dead? } }
        next sleep 0.25_f32.seconds unless all_dead

        break
      end

      break if _terminated
    end
  end
end

require "./caching/*"
require "./scanner/*"
require "./scanner/task/*"
