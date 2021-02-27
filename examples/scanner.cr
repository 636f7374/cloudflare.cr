require "../src/cloudflare.cr"
require "../serialization/serialization.cr"
require "../serialization/*"

text = %(---
subnets:
  - ipRange: 103.21.244.0/24
    expects:
      - name: bom
        priority: 0
        type: 0
      - name: ist
        priority: 1
        type: 0
    excludes:
      - name: sin
        type: 0
  - ipRange: 172.64.228.0/24
    expects:
      - name: nrt
        priority: 2
        type: 0
caching:
  ipAddressCapacityPerSubnet: 4
quirks:
  numberOfScansPerSubnet: 25
  maximumNumberOfFailuresPerSubnet: 15
  sleep: 2
  skipRange:
    - 3
    - 6
timeout:
  read: 2
  write: 2
  connect: 2)

serialization = Cloudflare::Serialization::Scanner.from_yaml text
options = serialization.to_options
scanner = Cloudflare::Scanner.new options: options

spawn do
  scanner.perform
end

loop do
  STDOUT.puts [scanner.caching.to_tuple_ipaddresses]
  sleep 10_f32.seconds
end
