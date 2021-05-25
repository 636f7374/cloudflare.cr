module Cloudflare::Serialized
  struct Scanner
    def unwrap(dns_resolver : ::DNS::Resolver? = nil) : Tuple(Set(Cloudflare::Task::Scanner::Expect), Cloudflare::Scanner)
      unwrapped_tasks = Set(Cloudflare::Task::Scanner::Expect).new

      tasks.each do |task|
        task.ipBlocks.each do |ip_block_text|
          ip_block = IPAddress.new addr: ip_block_text rescue nil
          next unless ip_block

          unwrapped_tasks << Cloudflare::Task::Scanner::Expect.new ipBlock: ip_block, entries: task.get_excluded_expects
        end
      end

      options_scanner = Cloudflare::Options::Scanner.new

      options_scanner.quirks = quirks.unwrap scanner: self
      options_scanner.caching = caching.unwrap
      options_scanner.timeout = timeout.unwrap
      options_scanner.attempt = attempt.unwrap

      options = Cloudflare::Options.new
      options.scanner = options_scanner
      options.dns = dns.unwrap dns_options: dns_resolver.options if dns_resolver

      Tuple.new unwrapped_tasks, Cloudflare::Scanner.new endpoint: endpoint.unwrap, options: options
    end

    struct DNS
      include YAML::Serializable

      property addrinfoOverride : Bool
      property socket : ::DNS::Serialized::Options::Standard::Socket

      def initialize(@addrinfoOverride : Bool = true, @socket : ::DNS::Serialized::Options::Standard::Socket = ::DNS::Serialized::Options::Standard::Socket.new)
      end

      def unwrap(dns_options : ::DNS::Options) : ::DNS::Options
        _dns_options = dns_options.dup
        _dns_options.socket = socket.unwrap

        _dns_options
      end
    end
  end
end
