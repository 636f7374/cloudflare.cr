require "../src/cloudflare.cr"
require "../serialized/serialized.cr"
require "../serialized/*"

text = %(---
controller:
  executableName: cloudflare
  listenAddress: tcp://0.0.0.0:6327
  reusePort: true
  timeout:
    client:
      read: 60
      write: 60
      connect: 20
    server:
      read: 60
      write: 60
      connect: 20
  flushIntervalWhenEmptyEntries: 5
  flushInterval: 10
  maximumNumberOfBytesReceivedEachTime: 101372
  type: external
tasks:
  - ipBlocks:
      - 45.133.247.0/24
      - 185.221.160.0/24
      - 185.174.138.0/24
      - 191.101.251.0/24
      - 104.21.75.0/24
    expects:
      - name: asia
        priority: 1
        type: region
      - name: north_america
        priority: 2
        type: region
      - name: latin_america_the_caribbean
        priority: 2
        type: region
      - name: oceania
        priority: 2
        type: region
      - name: middle_east
        priority: 2
        type: region
      - name: africa
        priority: 2
        type: region
  - ipBlocks:
      - 172.64.96.0/24
      - 172.64.101.0/24
      - 172.64.98.0/24
      - 172.64.200.0/24
      - 172.67.216.0/24
    expects:
      - name: asia
        priority: 1
        type: region
      - name: north_america
        priority: 2
        type: region
      - name: latin_america_the_caribbean
        priority: 2
        type: region
      - name: oceania
        priority: 2
        type: region
      - name: middle_east
        priority: 2
        type: region
      - name: africa
        priority: 2
        type: region
caching:
  ipAddressCapacityPerIpBlock: 2
  clearInterval: 30
quirks:
  numberOfScansPerIpBlock: 50
  maximumNumberOfFailuresPerIpBlock: 15
  numberOfSleepPerRequest: 0
  numberOfSleepPerRound: 0
  skipRange:
    - 0
    - 0
dns:
  addrinfoOverride: true
  socket:
    maximumNumberOfRetriesForPerIpAddress: 1
    maximumNumberOfRetriesForIpv4ConnectionFailure: 6
    maximumNumberOfRetriesForIpv6ConnectionFailure: 2
endpoint:
  method: GET
  path: /__down?bytes=256000
  port: 443
  headers:
    - User-Agent: "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/534.50 (KHTML, like Gecko) Version/5.1 Safari/534.50"
      Accept: "application/octet-stream"
      Accept-Language: "en-US,en;q=0.5"
      Connection: "keep-alive"
      Host: "speed.cloudflare.com:$PORT"
      Upgrade-Insecure-Requests: "1"
  tls:
    hostname: speed.cloudflare.com
    verifyMode: peer
    options:
      - no_ssl_v2
      - no_ssl_v3
      - no_tls_v1
      - no_tls_v1_1
      - no_tls_v1_2
attempt:
  connect: 3
timeout:
  tcp:
    read: 10
    write: 10
    connect: 10
  tls:
    read: 10
    write: 10
    connect: 10)

serialized = Cloudflare::Serialized::Scanner.from_yaml text
task_expects, scanner = serialized.unwrap

spawn do
  scanner.perform task_expects: task_expects
end

loop do
  STDOUT.puts [scanner.caching.to_tuple_ip_addresses]
  STDOUT.puts

  sleep 10_f32.seconds
end
