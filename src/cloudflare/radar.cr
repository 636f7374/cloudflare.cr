class Cloudflare::Radar
  getter storage : Storage
  getter options : Options
  getter numberOfTasks : Atomic(Int64)
  getter numberOfTasksCompleted : Atomic(Int64)

  def initialize(@storage : Storage = Storage.new, @options : Options = Options.new)
    @numberOfTasks = Atomic.new 0_i64
    @numberOfTasksCompleted = Atomic.new 0_i64
  end

  def number_of_tasks : Int64
    numberOfTasks.get
  end

  def number_of_tasks_completed : Int64
    numberOfTasksCompleted.get
  end

  private def reset_tasks_number : Bool
    numberOfTasks.set 0_i64
    numberOfTasksCompleted.set 0_i64

    true
  end

  def perform
    reset_tasks_number

    prefix24_set = to_prefix_24 subnets: get_subnets
    numberOfTasks.set prefix24_set.size.to_i64

    concurrent_process_task subnets: prefix24_set
  end

  private def to_prefix_24(subnets : Set(IPAddress::IPv4 | IPAddress::IPv6)) : Set(IPAddress::IPv4 | IPAddress::IPv6)
    concurrent_mutex = Mutex.new :unchecked
    concurrent_fibers = Array(Fiber).new
    list = Set(IPAddress::IPv4 | IPAddress::IPv6).new

    subnets.each do |ip_range|
      task_fiber = spawn do
        if (ip_range.prefix < 24_i32) && ip_range.is_a?(IPAddress::IPv4)
          ip_range.each do |ip_address|
            break unless ip_address.is_a? IPAddress::IPv4
            next unless ip_address.octets.last.zero?

            concurrent_mutex.synchronize { list << IPAddress.new String.build { |io| io << ip_address.address << "/24" } }
          end

          next
        end

        list << ip_range
      end

      concurrent_mutex.synchronize { concurrent_fibers << task_fiber }
    end

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

  private def process_task(subnets_iterator, mutex : Mutex, fibers : Array(Fiber)) : Bool
    loop do
      break if mutex.synchronize { fibers.size == options.radar.concurrentCount }
      subnets_iterator_next = subnets_iterator.next
      break if subnets_iterator_next.is_a? Iterator::Stop

      task_fiber = spawn do
        task = Task.new ipRange: subnets_iterator_next, storage: storage, options: options
        task.perform
      end

      mutex.synchronize { fibers << task_fiber }
    end

    true
  end

  private def concurrent_process_task(subnets : Set(IPAddress::IPv4 | IPAddress::IPv6))
    concurrent_mutex = Mutex.new :unchecked
    concurrent_fibers = Array(Fiber).new

    subnets_iterator = subnets.each
    process_task subnets_iterator: subnets_iterator, mutex: concurrent_mutex, fibers: concurrent_fibers

    loop do
      concurrent_mutex.synchronize do
        concurrent_fibers.each do |fiber|
          if fiber.dead?
            concurrent_fibers.delete fiber
            numberOfTasksCompleted.add 1_i32
          end
        end
      end

      process_task subnets_iterator: subnets_iterator, mutex: concurrent_mutex, fibers: concurrent_fibers
      all_dead = concurrent_mutex.synchronize { concurrent_fibers.empty? }
      next sleep 0.25_f32.seconds unless all_dead
      storage.clear_if_only_needles options: options

      break
    end
  end
end

require "http/request"
require "./radar/*"
