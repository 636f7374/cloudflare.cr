class Cloudflare::Scanner
  getter caching : Caching::Scanner
  getter endpoint : Endpoint
  getter options : Options
  getter terminated : Bool
  getter running : Bool
  getter mutex : Mutex

  def initialize(@caching : Caching::Scanner, @endpoint : Endpoint, @options : Options)
    @terminated = false
    @running = false
    @mutex = Mutex.new :unchecked
  end

  def self.new(endpoint : Endpoint, options : Options)
    caching = Cloudflare::Caching::Scanner.new options: options
    new caching: caching, endpoint: endpoint, options: options
  end

  def caching_to_tuple_ip_addresses : Array(Tuple(Needles::IATA, Socket::IPAddress))
    caching.to_tuple_ip_addresses
  end

  def terminate
    @mutex.synchronize { @terminated = true }
  end

  def perform(tasks : Set(Task::Scanner::Entry))
    raise Exception.new "Scanner.perform: Scanner is already running!" if @mutex.synchronize { running.dup }
    raise Exception.new "Scanner.perform: Scanner has terminated!" if @mutex.synchronize { terminated.dup }
    @mutex.synchronize { @running = true }

    loop do
      concurrent_mutex = Mutex.new :unchecked
      concurrent_fibers = Set(Fiber).new
      _terminated = false

      tasks.each do |entry|
        task_fiber = spawn do
          task = Task::Scanner.new entry: entry, caching: caching, options: options
          task.perform endpoint: endpoint
        end

        concurrent_mutex.synchronize { concurrent_fibers << task_fiber }
      end

      loop do
        _terminated = @mutex.synchronize { terminated.dup }
        break @mutex.synchronize { @running = false } if _terminated

        all_dead = concurrent_mutex.synchronize { concurrent_fibers.all? { |fiber| fiber.dead? } }
        next sleep 0.25_f32.seconds unless all_dead

        sleep options.scanner.quirks.numberOfSleepPerRound

        break
      end

      break if _terminated
    end
  end
end

require "http/request"
require "./task/*"
require "./caching/*"
