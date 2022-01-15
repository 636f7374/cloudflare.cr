module Cloudflare::CommandLine
  def self.parse(args : Array(String) = ARGV)
    ::OptionParser.parse args: args do |parser|
      parser.banner = "Usage: cloudflare [command] [--] [arguments]"

      parser.on "scanner", "Run Cloudflare Scanner Subfunction." do
      end

      parser.on "radar", "Run Cloudflare Radar Subfunction." do
      end

      parser.on "-v", "--version", "Get version information of this Cloudflare." do
        value = %(    Cloudflare.cr - Cloudflare Radar and Booster\n    Version: #{Cloudflare::VERSION} (#{Cloudflare::RELEASE_DATE}))
        STDOUT.puts value

        abort
      end

      parser.on "-h", "--help", "Get help information for this Cloudflare." do
        STDOUT.puts parser

        abort
      end
    end
  end
end

require "option_parser"
require "./command_line/*"
