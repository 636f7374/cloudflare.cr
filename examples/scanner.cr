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
      - 172.64.228.0/24
    expects:
      - name: nrt
        priority: 2
        type: iata
caching:
  ipAddressCapacityPerIpBlock: 4
  clearInterval: 30
quirks:
  numberOfScansPerIpBlock: 50
  maximumNumberOfFailuresPerIpBlock: 25
  numberOfSleepPerRequest: 0
  numberOfSleepPerRound: 10
  skipRange:
    - 1
    - 2
endpoint:
  port: 80
  method: GET
  path: /__down?bytes=64
  headers:
    - User-Agent: "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/534.50 (KHTML, like Gecko) Version/5.1 Safari/534.50"
      Accept: "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
      Accept-Language: "en-US,en;q=0.5"
      Connection: "keep-alive"
      Host: "speed.cloudflare.com:80"
      Upgrade-Insecure-Requests: "1"
switcher:
  addrinfoOverride: true
timeout:
  read: 2
  write: 2
  connect: 2)

serialized = Cloudflare::Serialized::Scanner.from_yaml text
tasks, scanner = serialized.unwrap

spawn do
  scanner.perform tasks: tasks
end

loop do
  STDOUT.puts [scanner.caching.to_tuple_ip_addresses]
  STDOUT.puts

  sleep 10_f32.seconds
end
