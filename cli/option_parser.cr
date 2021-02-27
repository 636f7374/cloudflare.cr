module Cloudflare::CommandLine
  class OptionParser
    property import : Cloudflare::Serialization::Import?

    def initialize(@import : Cloudflare::Serialization::Import? = nil)
    end

    def get! : Tuple(Cloudflare::Serialization::Import, String)
      abort "Error: Radar import information is not specified!" unless _import = import
      abort "Error: No Radar output path specified!" unless output_path = _import.outputPath

      output_path = output_path.gsub "$HOME", (ENV["HOME"]? || String.new)
      Tuple.new _import, output_path
    end

    def parse(args : Array(String) = ARGV)
      ::OptionParser.parse args: args do |parser|
        parser.banner = "Usage: radar [command] [--] [arguments]"

        parser.on "-i +", "--import +", "Specify Radar configuration file path." do |path|
          @import = Cloudflare::Serialization::Import.from_json File.read(filename: path)
        end

        parser.on "-o +", "--output +", "Specify the output path of the Radar." do |path|
          @import.try &.outputPath = path
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
