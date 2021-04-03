class Cloudflare::Radar
  getter storage : Storage
  getter options : Options
  getter numberOfTasks : Atomic(UInt64)
  getter numberOfTasksCompleted : Atomic(UInt64)

  def initialize(@storage : Storage = Storage.new, @options : Options = Options.new)
    @numberOfTasks = Atomic.new 0_u64
    @numberOfTasksCompleted = Atomic.new 0_u64
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

  def perform : Bool
    reset_tasks_number

    prefix24_set = to_prefix_24 subnets: get_subnets
    numberOfTasks.set prefix24_set.size.to_u64
    concurrent_process_task subnets: prefix24_set

    true
  end

  private def to_prefix_24(subnets : Set(IPAddress::IPv4 | IPAddress::IPv6)) : Set(IPAddress::IPv4 | IPAddress::IPv6)
    concurrent_mutex = Mutex.new :unchecked
    concurrent_fibers = Set(Fiber).new
    list_mutex = Mutex.new :unchecked
    list = Set(IPAddress::IPv4 | IPAddress::IPv6).new

    main_concurrent_fiber = spawn do
      subnets.each do |subnet|
        task_fiber = spawn do
          if (subnet.prefix < 24_i32) && subnet.is_a?(IPAddress::IPv4)
            subnet.subnets(24_i32).each do |prefix_24_subnet|
              list_mutex.synchronize { list << prefix_24_subnet }
            end

            next
          end

          list_mutex.synchronize { list << subnet }
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

  private def get_subnets : Set(IPAddress::IPv4 | IPAddress::IPv6)
    case options.radar.scanIpAddressType
    in .ipv4_only?
      Subnet::Ipv4
    in .ipv6_only?
      Subnet::Ipv6
    in .both?
      list = Set(Set(IPAddress::IPv4 | IPAddress::IPv6)).new
      list << Subnet::Ipv4
      list << Subnet::Ipv6

      list.map(&.to_a).flatten.to_set
    end
  end

  private def concurrent_process_task(subnets : Set(IPAddress::IPv4 | IPAddress::IPv6))
    concurrent_mutex = Mutex.new :unchecked
    concurrent_fibers = Array(Fiber).new
    subnets_iterator = subnets.each

    main_concurrent_fiber = spawn do
      loop do
        if concurrent_mutex.synchronize { concurrent_fibers.size == options.radar.concurrentCount }
          sleep 0.25_f32.seconds

          next
        end

        subnets_iterator_next = subnets_iterator.next
        break if subnets_iterator_next.is_a? Iterator::Stop

        task_fiber = spawn do
          task = Task.new ipRange: subnets_iterator_next, storage: storage, options: options
          task.perform
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
