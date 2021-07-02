require "./src/cloudflare.cr"
require "./serialized/serialized.cr"
require "./serialized/*"
require "./cli/*"

case ARGV[0_i32]? || String.new
when "radar"
  option_parser = Cloudflare::CommandLine::Radar::OptionParser.parse args: ARGV
  Cloudflare::CommandLine::Radar.perform option_parser: option_parser
when "scanner"
  option_parser = Cloudflare::CommandLine::Scanner::OptionParser.parse args: ARGV
  Cloudflare::CommandLine::Scanner.perform option_parser: option_parser
else
  Cloudflare::CommandLine.parse args: ARGV
end
