module Cloudflare::Serialized
  module Export
    struct Scanner
      include JSON::Serializable

      property entries : Hash(String, Array(Entry))
      property latestCleanedUp : Time

      def initialize(@entries : Hash(String, Array(Entry)), @latestCleanedUp : Time)
      end

      def unwrap_entries! : Hash(IPAddress, Set(Cloudflare::Caching::Scanner::Entry))
        unwrapped_entries = Hash(IPAddress, Set(Cloudflare::Caching::Scanner::Entry)).new

        entries.each do |ip_block, ip_block_entries|
          ip_block = IPAddress.new addr: ip_block
          unwrapped_ip_block_entries = unwrapped_entries[ip_block]? || Set(Cloudflare::Caching::Scanner::Entry).new

          ip_block_entries.each { |entry| unwrapped_ip_block_entries << entry.unwrap }
          unwrapped_entries[ip_block] = unwrapped_ip_block_entries
        end

        unwrapped_entries
      end

      struct Entry
        include JSON::Serializable

        property iata : Needles::IATA
        property priority : UInt8
        property ipAddress : String
        property createdAt : Time

        def initialize(@iata : Needles::IATA, @priority : UInt8, @ipAddress : String, @createdAt : Time)
        end

        def unwrap : Cloudflare::Caching::Scanner::Entry
          host, delimiter, port = ipAddress.rpartition ':'
          raise Exception.new "Serialized::Export::Scanner::Entry.unwrap: ipAddress.port is non Integer Type." unless _port = port.to_i?
          ip_address = Socket::IPAddress.new address: host, port: _port

          entry = Cloudflare::Caching::Scanner::Entry.new iata: iata, priority: priority, ipAddress: ip_address
          entry.createdAt = createdAt

          entry
        end
      end
    end
  end
end
