class Cloudflare::Scanner
  getter tasks : Set(Task::Entry)
  getter caching : Caching::Scanner
  getter options : Options
  getter terminated : Bool
  getter running : Bool
  getter mutex : Mutex

  def initialize(@tasks : Set(Task::Entry), @caching : Caching::Scanner, @options : Options)
    @terminated = false
    @running = false
    @mutex = Mutex.new :unchecked
  end

  def self.new(tasks : Set(Task::Entry), options : Options)
    caching = Cloudflare::Caching::Scanner.new options: options
    new tasks: tasks, caching: caching, options: options
  end

  def caching_to_tuple_ip_addresses : Array(Tuple(Needles::IATA, Socket::IPAddress))
    caching.to_tuple_ip_addresses
  end

  def terminate
    @mutex.synchronize { @terminated = true }
  end

  def perform
    raise Exception.new "Scanner.perform: Scanner is already running!" if @mutex.synchronize { running.dup }
    raise Exception.new "Scanner.perform: Scanner has terminated!" if @mutex.synchronize { terminated.dup }
    @mutex.synchronize { @running = true }

    loop do
      concurrent_mutex = Mutex.new :unchecked
      concurrent_fibers = Set(Fiber).new
      _terminated = false

      tasks.each do |entry|
        task_fiber = spawn do
          task = Task.new entry: entry, caching: caching, options: options
          task.perform
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
require "./caching/*"
require "./scanner/*"
