module Cloudflare::CommandLine
  class OptionParser
    property radar : Serialized::Radar::Standard | Serialized::Radar::Callee | Nil
    property externalController : TCPSocket | UNIXSocket | Nil

    def initialize(@radar : Serialized::Radar::Standard | Serialized::Radar::Callee | Nil = nil)
      @externalController = nil
    end

    def self.parse(args : Array(String) = ARGV) : OptionParser
      option_parser = new
      option_parser.parse args: args

      option_parser
    end

    def get_radar! : Serialized::Radar::Standard | Serialized::Radar::Callee
      abort "Error: CommandLine::OptionParser.radar is Nil!" unless _radar = get_external_controller_radar! || radar

      _radar
    end

    def get_external_controller_radar!
      return unless external_controller = externalController
      return if radar

      length = external_controller.read_bytes UInt32, IO::ByteFormat::BigEndian

      memory = IO::Memory.new length
      copy_length = IO.copy external_controller, memory, length
      @radar = serialized_callee = Serialized::Radar::Callee.from_yaml String.new memory.to_slice[0_i32, copy_length]

      serialized_callee
    end

    def parse(args : Array(String) = ARGV)
      ::OptionParser.parse args: args do |parser|
        parser.banner = "Usage: cloudflare [command] [--] [arguments]"

        parser.on "-e +", "--external-controller +", "Specify the Controller of the Radar." do |address|
          case _address = Socket::Address.parse address
          in Socket::IPAddress
            @externalController = socket = TCPSocket.new host: _address.address, port: _address.port
          in Socket::UNIXAddress
            @externalController = socket = UNIXSocket.new path: _address.path
          in Socket::Address
            abort "OptionParser.parse: Unknown externalController.address type (not IPAddress or UNIXAddress)."
          end

          socket.read_timeout = 10_i32.seconds
          socket.write_timeout = 10_i32.seconds
        end

        parser.on "-i +", "--import +", "Specify Radar configuration file path." do |path|
          serialized_standard = Serialized::Radar::Standard.from_yaml File.read(filename: path)
          serialized_standard.try { |standard| @radar = standard }
        end

        parser.on "-o +", "--output +", "Specify the output path of the Radar." do |path|
          next unless _radar = @radar
          next unless _radar.is_a? Serialized::Radar::Standard

          _radar.outputPath = path
        end

        parser.on "-v", "--version", "Get version information of this Radar." do
          value = %(    Cloudflare.cr - Cloudflare Radar and Booster\n    Version: #{Cloudflare::VERSION} (#{Cloudflare::LATEST_RELEASE_DATE}))
          STDOUT.puts value

          abort
        end

        parser.on "-h", "--help", "Get help information for this Radar." do
          STDOUT.puts parser

          abort
        end
      end
    end
  end
end
