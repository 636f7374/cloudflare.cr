module Cloudflare::CommandLine
  class ExternalController
    getter io : Socket
    getter calleeSet : Set(Serialized::Radar::Callee)
    getter exports : Set(Serialized::Export)
    getter clients : Set(Socket)
    getter mutex : Mutex

    def initialize(@io : Socket, @calleeSet : Set(Serialized::Radar::Callee))
      @exports = Set(Serialized::Export).new
      @clients = Set(Socket).new
      @mutex = Mutex.new :unchecked
    end

    def close
      mutex.synchronize { @io.close rescue nil }
    end

    def done?
      mutex.synchronize { clients.empty? && (calleeSet.size.zero?) }
    end

    def get_serialized_callee? : Serialized::Radar::Callee?
      mutex.synchronize do
        callee_set = @calleeSet
        return unless callee_set_first = callee_set.first?

        callee_set.delete callee_set_first
        @calleeSet = callee_set

        callee_set_first
      end
    end

    def add_callee(callee : Serialized::Radar::Callee)
      mutex.synchronize { @calleeSet << callee }

      true
    end

    def add_export(export : Serialized::Export)
      mutex.synchronize { @exports << export }

      true
    end

    def get_exports : Set(Serialized::Export)
      mutex.synchronize { @exports.dup }
    end

    def add_client(client : Socket)
      mutex.synchronize { @clients << client }

      true
    end

    def delete_client(client : Socket)
      mutex.synchronize do
        _clients = @clients
        _clients.delete client

        @clients = _clients
      end

      true
    end

    def get_clients : Set(TCPSocket | UNIXSocket)
      mutex.synchronize { @client.dup }
    end

    def perform
      loop do
        _client = io.accept? rescue nil
        next unless client = _client

        _client.read_timeout = 10_i32.seconds
        _client.write_timeout = 10_i32.seconds

        spawn do
          unless serialized_callee = get_serialized_callee?
            _client.close rescue nil

            next
          end

          begin
            add_client client: client

            slice = serialized_callee.to_json.to_slice
            client.write_bytes slice.size, IO::ByteFormat::BigEndian
            client.write slice: slice
            client.flush
          rescue ex
            client.close rescue nil

            add_callee callee: serialized_callee
            delete_client client: client

            next
          end

          loop do
            begin
              length = client.read_bytes UInt32, IO::ByteFormat::BigEndian
              memory = IO::Memory.new length
              copy_length = IO.copy client, memory, length
              text_message = String.new memory.to_slice[0_i32, copy_length]

              progress = Serialized::Frames::Radar::Progress.from_json text_message rescue nil
              export = Serialized::Export.from_yaml text_message rescue nil unless progress
            rescue ex
              client.close rescue nil

              add_callee callee: serialized_callee
              delete_client client: client

              break
            end

            if export
              client.close rescue nil

              add_export export: export
              delete_client client: client

              break
            end

            sleep 0.05_f32.seconds
          end
        end
      end
    end
  end
end
