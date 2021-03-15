require "../src/cloudflare.cr"
require "../serialized/serialized.cr"
require "../serialized/*"

text = %(---
subnets:
  - ipRange: 103.21.244.0/24
    expects:
      - name: bom
        priority: 0
        type: iata
      - name: ist
        priority: 2
        type: iata
    excludes:
      - name: sin
        type: iata
  - ipRange: 172.64.228.0/24
    expects:
      - name: nrt
        priority: 1
        type: iata
caching:
  ipAddressCapacityPerSubnet: 4
  clearInterval: 30
quirks:
  numberOfScansPerSubnet: 50
  maximumNumberOfFailuresPerSubnet: 25
  sleep: 1
  skipRange:
    - 1
    - 2
switcher:
  getaddrinfoOverride: true
timeout:
  read: 2
  write: 2
  connect: 2)

serialized = Cloudflare::Serialized::Scanner.from_yaml text
scanner = serialized.unwrap

spawn do
  scanner.perform
end

loop do
  STDOUT.puts [scanner.caching.to_tuple_ip_addresses]
  STDOUT.puts

  sleep 10_f32.seconds
end
