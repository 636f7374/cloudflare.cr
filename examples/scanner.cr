require "../src/cloudflare.cr"
require "../serialization/serialization.cr"
require "../serialization/*"

text = %(---
subnets:
  - ipRange: 103.21.244.0/24
    expects:
      - name: bom
        priority: 0
        type: iata
      - name: ist
        priority: 1
        type: iata
    excludes:
      - name: sin
        type: iata
  - ipRange: 172.64.228.0/24
    expects:
      - name: nrt
        priority: 2
        type: iata
caching:
  ipAddressCapacityPerSubnet: 4
quirks:
  numberOfScansPerSubnet: 50
  maximumNumberOfFailuresPerSubnet: 25
  sleep: 2
  skipRange:
    - 1
    - 2
timeout:
  read: 2
  write: 2
  connect: 2)

serialization = Cloudflare::Serialization::Scanner.from_yaml text
options = serialization.unwrap
scanner = Cloudflare::Scanner.new options: options

spawn do
  scanner.perform
end

loop do
  STDOUT.puts [scanner.caching.to_tuple_ipaddresses]
  STDOUT.puts

  sleep 10_f32.seconds
end
