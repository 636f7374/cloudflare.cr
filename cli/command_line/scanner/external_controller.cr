module Cloudflare::CommandLine
  module Scanner
    class ExternalController
      getter io : Socket
      getter scanner : Cloudflare::Scanner
      getter serializedController : Serialized::Scanner::Controller::External
      getter mutex : Mutex

      def initialize(@io : Socket, @scanner : Cloudflare::Scanner, @serializedController : Serialized::Scanner::Controller::External)
        @mutex = Mutex.new :unchecked
      end

      def close
        mutex.synchronize { @io.close rescue nil }
      end

      def perform
        loop do
          _client = io.accept? rescue nil
          next unless client = _client

          client.read_timeout = serializedController.timeout.server.read.seconds
          client.write_timeout = serializedController.timeout.server.write.seconds

          spawn do
            buffer = uninitialized UInt8[1_i32]

            loop do
              begin
                read_length = client.read buffer.to_slice
                raise Exception.new "CommandLine::Scanner::ExternalController.perform: Client read_length is zero!" if read_length.zero?

                flag = ScannerControllerFlag.new buffer.to_slice.first

                case flag
                in .fetch?
                  serialized = scanner.caching.to_serialized.to_json

                  client.write_bytes serialized.size, IO::ByteFormat::BigEndian
                  client.flush

                  client.write serialized.to_slice
                  client.flush
                end
              rescue ex
                client.close rescue nil

                break
              end
            end
          end
        end
      end
    end
  end
end
