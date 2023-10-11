module Cloudflare::Serialized
  struct Scanner
    abstract struct Controller
      include YAML::Serializable

      getter type : String

      use_yaml_discriminator "type", {
        "external" => External,
        "built_in" => BuiltIn,
      }

      struct External < Controller
        property executableName : String
        property listenAddress : String
        property reusePort : Bool
        property timeout : TimeOut
        property flushIntervalWhenEmptyEntries : UInt8
        property flushInterval : UInt8
        property maximumNumberOfBytesReceivedEachTime : UInt32

        def initialize(@executableName : String, @listenAddress : String, @reusePort : Bool, @timeout : TimeOut, @flushIntervalWhenEmptyEntries : UInt8,
                       @flushInterval : UInt8, @maximumNumberOfBytesReceivedEachTime : UInt32)
          @type = "external"
        end

        def get_listen_address! : Socket::Address
          Socket::Address.parse listenAddress
        end

        def unwrap_client : TCPSocket | UNIXSocket
          case listen_address = get_listen_address!
          in Socket::IPAddress
            TCPSocket.new ip_address: listen_address, connect_timeout: timeout.client.connect.seconds
          in Socket::UNIXAddress
            UNIXSocket.new path: listenAddress
          in Socket::Address
            abort "Controller.unwrap: Unknown Controller.listenAddress type (not IPAddress or UNIXAddress)."
          end
        end

        def unwrap_server : TCPServer | UNIXServer
          case listen_address = get_listen_address!
          in Socket::IPAddress
            server = TCPServer.new host: listen_address.address, port: listen_address.port
            server.reuse_port = reusePort

            server
          in Socket::UNIXAddress
            server = UNIXServer.new path: listen_address.path
            server.reuse_port = reusePort

            server
          in Socket::Address
            abort "Controller.unwrap: Unknown Controller.listenAddress type (not IPAddress or UNIXAddress)."
          end
        end

        struct TimeOut
          include YAML::Serializable

          property client : Cloudflare::Serialized::TimeOut
          property server : Cloudflare::Serialized::TimeOut

          def initialize(@client : Cloudflare::Serialized::TimeOut, @server : Cloudflare::Serialized::TimeOut)
          end
        end
      end

      struct BuiltIn < Controller
        def initialize
          @type = "built_in"
        end
      end
    end
  end
end
