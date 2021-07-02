module Cloudflare::Caching
  class Scanner
    getter options : Options
    getter entries : Hash(IPAddress, Set(Entry))
    getter latestCleanedUp : Time
    getter mutex : Mutex

    def initialize(@options : Options)
      @entries = Hash(IPAddress, Set(Entry)).new
      @latestCleanedUp = Time.local
      @mutex = Mutex.new :unchecked
    end

    def external_controller=(value : Bool)
      @mutex.synchronize { @externalController = value }
    end

    def external_controller
      @externalController
    end

    def restore(serialized_export : Serialized::Export::Scanner)
      @mutex.synchronize do
        @entries = serialized_export.unwrap_entries!
        @latestCleanedUp = serialized_export.latestCleanedUp
      end

      true
    end

    private def refresh_latest_cleaned_up
      @mutex.synchronize { @latestCleanedUp = Time.local }
    end

    private def need_cleared? : Bool
      interval = Time.local - latestCleanedUp
      interval > options.scanner.caching.clearInterval
    end

    private def inactive_entry_cleanup : Bool
      return false unless need_cleared?

      starting_time = Time.local

      entries.each do |ip_block, entry_set|
        temporary_set = Set(Entry).new

        entry_set.each do |entry|
          next if options.scanner.caching.clearInterval <= (starting_time - entry.createdAt)
          temporary_set << entry
        end

        entries[ip_block] = temporary_set
      end

      true
    end

    def set(ip_block : IPAddress, iata : Needles::IATA, priority : UInt8, ip_address : Socket::IPAddress)
      @mutex.synchronize do
        inactive_entry_cleanup
        entry_set = entries[ip_block] ||= Set(Entry).new

        if entry_set.size < options.scanner.caching.ipAddressCapacityPerIpBlock
          entry_set << Entry.new iata: iata, priority: priority, ipAddress: ip_address
          entries[ip_block] = entry_set

          return
        end

        iata_count = entry_set.count { |entry| iata == entry.iata }
        percentage = ((iata_count / entry_set.size) * 100_i32).round.to_i32

        case iata_count
        when .zero?
          entry_set.delete entry_set.first
          entry_set << Entry.new iata: iata, priority: priority, ipAddress: ip_address
          entries[ip_block] = entry_set
        else
          case percentage
          when .< 50_i32
            entry_set.each do |entry|
              next if iata == entry.iata

              entry_set.delete entry
              entry_set << Entry.new iata: iata, priority: priority, ipAddress: ip_address
              entries[ip_block] = entry_set

              return
            end
          else
            entry_set.each do |entry|
              next unless iata == entry.iata

              entry_set.delete entry
              entry_set << Entry.new iata: iata, priority: priority, ipAddress: ip_address
              entries[ip_block] = entry_set

              return
            end
          end
        end
      end
    end

    def to_tuple_ip_addresses : Array(Tuple(Needles::IATA, Socket::IPAddress))
      _entries_dup = dup
      list = [] of Tuple(UInt8, Needles::IATA, Socket::IPAddress)

      _entries_dup.each do |ip_block, entry_set|
        entry_set.each { |entry| list << Tuple.new entry.priority, entry.iata, entry.ipAddress }
      end

      list = list.sort { |x, y| x.first <=> y.first }

      list.map do |item|
        priority, iata, ip_address = item
        Tuple.new iata, ip_address
      end
    end

    def dup : Hash(IPAddress, Set(Entry))
      @mutex.synchronize { entries.dup }
    end

    def to_serialized_entries : Hash(String, Array(Serialized::Export::Scanner::Entry))
      serialized_entries = Hash(String, Array(Serialized::Export::Scanner::Entry)).new
      _dup = dup

      _dup.each do |ip_block, _entries|
        _ip_block = String.build { |io| io << ip_block.address << '/' << ip_block.prefix }
        ip_block_serialized_entries = serialized_entries[_ip_block]? || Array(Serialized::Export::Scanner::Entry).new
        _entries.each { |entry| ip_block_serialized_entries << entry.to_serialized }
        serialized_entries[_ip_block] = ip_block_serialized_entries
      end

      serialized_entries
    end

    def to_serialized : Serialized::Export::Scanner
      Serialized::Export::Scanner.new entries: to_serialized_entries, latestCleanedUp: latestCleanedUp
    end

    struct Entry
      property iata : Needles::IATA
      property priority : UInt8
      property ipAddress : Socket::IPAddress
      property createdAt : Time

      def initialize(@iata : Needles::IATA, @priority : UInt8, @ipAddress : Socket::IPAddress)
        @createdAt = Time.local
      end

      def to_serialized : Serialized::Export::Scanner::Entry
        Serialized::Export::Scanner::Entry.new iata: iata, priority: priority, ipAddress: String.build { |io| io << ipAddress.address << ':' << ipAddress.port }, createdAt: createdAt
      end
    end
  end
end
