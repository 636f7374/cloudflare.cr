require "../src/cloudflare.cr"
require "../serialized/serialized.cr"
require "../serialized/*"

text = %(---
tasks:
  - ipBlocks:
      - 104.19.85.0/24
      - 104.19.86.0/24
    expects:
      - name: hkg
        priority: 0
        type: iata
  - ipBlocks:
      - 103.21.244.0/24
    expects:
      - name: bom
        priority: 1
        type: iata
      - name: ist
        priority: 3
        type: iata
    excludes:
      - name: sin
        type: iata
  - ipBlocks:
  172.64.228.0/24
      - expects:
      - name: nrt
        priority: 2
        type: iata
caching:
  ipAddressCapacityPerBlock: 4
  clearInterval: 30
quirks:
  numberOfScansPerBlock: 50
  maximumNumberOfFailuresPerBlock: 25
  sleep: 1
  skipRange:
    - 1
    - 2
switcher:
  addrinfoOverride: true
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
