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

  def perform(task_tuple : Tuple(Cloudflare::Serialized::Scanner::Controller::External, Proc(Process::Status)))
    raise Exception.new "Scanner.perform_external: Scanner is already running!" if @mutex.synchronize { running.dup }
    raise Exception.new "Scanner.perform_external: Scanner has terminated!" if @mutex.synchronize { terminated.dup }
    @mutex.synchronize { @running = true }
    serialized_external, sub_process_proc = task_tuple
    caching.external_controller = true

    loop do
      _terminated = @mutex.synchronize { terminated.dup }
      break @mutex.synchronize { @running = false } if _terminated

      sub_process_fiber = spawn { sub_process_proc.call }

      loop do
        break if sub_process_fiber.dead?

        _terminated = @mutex.synchronize { terminated.dup }
        break @mutex.synchronize { @running = false } if _terminated

        socket = serialized_external.unwrap_client rescue nil
        next sleep 5_i32.seconds unless socket

        socket.read_timeout = serialized_external.timeout.client.read.seconds
        socket.write_timeout = serialized_external.timeout.client.write.seconds

        temporary = IO::Memory.new

        loop do
          _terminated = @mutex.synchronize { terminated.dup }
          break @mutex.synchronize { @running = false } if _terminated

          begin
            socket.write Bytes[ScannerControllerFlag::FETCH.value]
            socket.flush
            copy_length = socket.read_bytes UInt32, IO::ByteFormat::BigEndian

            if copy_length > serialized_external.maximumNumberOfBytesReceivedEachTime
              message = String.build { |io| io << "Cloudflare::Scanner.perform: copy_length > External.maximumNumberOfBytesReceivedEachTime! (" << copy_length << '>' << serialized_external.maximumNumberOfBytesReceivedEachTime << ")." }

              raise Exception.new message
            end

            IO.copy socket, temporary, copy_length
            serialized_export = Cloudflare::Serialized::Export::Scanner.from_json String.new(temporary.to_slice)
            caching.restore serialized_export: serialized_export unless serialized_export.entries.empty?

            temporary.clear
            temporary.rewind

            flush_interval = serialized_export.entries.empty? ? serialized_external.flushIntervalWhenEmptyEntries : serialized_external.flushInterval
            sleep flush_interval.seconds
          rescue ex
            socket.close rescue nil

            temporary.clear
            temporary.rewind

            sleep serialized_external.flushIntervalWhenEmptyEntries

            break
          end
        end
      end

      sleep 5_i32.seconds
    end
  end

  def perform(task_expects : Set(Task::Scanner::Expect))
    raise Exception.new "Scanner.perform: Scanner is already running!" if @mutex.synchronize { running.dup }
    raise Exception.new "Scanner.perform: Scanner has terminated!" if @mutex.synchronize { terminated.dup }
    @mutex.synchronize { @running = true }

    loop do
      break if task_expects.empty?

      _terminated = @mutex.synchronize { terminated.dup }
      break @mutex.synchronize { @running = false } if _terminated

      concurrent_mutex = Mutex.new :unchecked
      concurrent_fibers = Set(Fiber).new
      _terminated = false

      task_expects.each do |task_expect|
        task_fiber = spawn do
          task = Task::Scanner.new expect: task_expect, caching: caching, options: options
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
