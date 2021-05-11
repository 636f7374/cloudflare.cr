class Cloudflare::Radar
  getter endpoint : Endpoint
  getter options : Options
  getter storage : Storage
  getter numberOfTasks : Atomic(UInt64)
  getter numberOfTasksCompleted : Atomic(UInt64)

  def initialize(@endpoint : Endpoint, @options : Options = Options.new)
    @storage = Storage.new
    @numberOfTasks = Atomic.new 0_u64
    @numberOfTasksCompleted = Atomic.new 0_u64
  end

  def options
    @options
  end

  def storage : Storage
    @storage
  end

  def number_of_tasks : UInt64
    numberOfTasks.get
  end

  def number_of_tasks_completed : UInt64
    numberOfTasksCompleted.get
  end

  private def reset_tasks_number : Bool
    numberOfTasks.set 0_u64
    numberOfTasksCompleted.set 0_u64

    true
  end

  def perform(ip_blocks : Set(IPAddress::IPv4 | IPAddress::IPv6)) : Bool
    reset_tasks_number
    numberOfTasks.set ip_blocks.size.to_u64

    concurrent_process_task ip_blocks: ip_blocks

    true
  end

  private def concurrent_process_task(ip_blocks : Set(IPAddress::IPv4 | IPAddress::IPv6))
    concurrent_mutex = Mutex.new :unchecked
    concurrent_fibers = Array(Fiber).new
    ip_blocks_iterator = ip_blocks.each

    main_concurrent_fiber = spawn do
      loop do
        if concurrent_mutex.synchronize { concurrent_fibers.size == options.radar.concurrentCount }
          sleep 0.25_f32.seconds

          next
        end

        ip_blocks_iterator_next = ip_blocks_iterator.next
        break if ip_blocks_iterator_next.is_a? Iterator::Stop

        task_fiber = spawn do
          task = Task.new ipBlock: ip_blocks_iterator_next, storage: storage, options: options
          task.perform endpoint: endpoint
        end

        concurrent_mutex.synchronize { concurrent_fibers << task_fiber }
      end
    end

    concurrent_mutex.synchronize { concurrent_fibers << main_concurrent_fiber }

    loop do
      concurrent_mutex.synchronize do
        concurrent_fibers.each do |fiber|
          if fiber.dead?
            concurrent_fibers.delete fiber
            next if numberOfTasks.get == numberOfTasksCompleted.get

            numberOfTasksCompleted.add 1_i32
          end
        end
      end

      all_dead = concurrent_mutex.synchronize { concurrent_fibers.empty? }
      next sleep 0.25_f32.seconds unless all_dead
      storage.exclude options: options

      break
    end
  end
end

require "http/request"
require "./radar/*"
