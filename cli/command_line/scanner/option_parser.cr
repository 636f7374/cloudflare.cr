module Cloudflare::CommandLine
  module Scanner
    class OptionParser
      property scanner : Serialized::Scanner?

      def initialize(@scanner : Serialized::Scanner? = nil)
      end

      def self.parse(args : Array(String) = ARGV) : OptionParser
        option_parser = new
        option_parser.parse args: args

        option_parser
      end

      def parse(args : Array(String) = ARGV)
        ::OptionParser.parse args: args do |parser|
          parser.banner = "Usage: cloudflare scanner [command] [--] [arguments]"

          parser.on "--payload +", "Specify Scanner configuration Payload." do |payload|
            payload_text = Base64.decode_string payload

            unwrapped = Serialized::Scanner.from_yaml payload_text
            unwrapped.try { |_unwrapped| @scanner = _unwrapped }
          end

          parser.on "-h", "--help", "Show this help." do
            STDOUT.puts parser

            abort
          end
        end
      end
    end
  end
end
