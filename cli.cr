require "./src/cloudflare.cr"
require "./serialized/serialized.cr"
require "./serialized/*"
require "./cli/*"

option_parser = Cloudflare::CommandLine::OptionParser.parse args: ARGV
Cloudflare::CommandLine.perform option_parser: option_parser
