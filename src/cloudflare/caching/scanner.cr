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

    private def refresh_latest_cleaned_up
      @mutex.synchronize { @latestCleanedUp = Time.local }
    end

    private def need_cleared? : Bool
      interval = Time.local - (@mutex.synchronize { latestCleanedUp.dup })
      interval > options.scanner.caching.clearInterval
    end

    private def inactive_entry_cleanup : Bool
      return false unless need_cleared?

      @mutex.synchronize do
        time_local = Time.local

        entries.each do |ip_block, entry_set|
          temporary_set = Set(Entry).new

          entry_set.each do |entry|
            next if (time_local - entry.createdAt) > options.scanner.caching.clearInterval
            temporary_set << entry
          end

          entries[ip_block] = temporary_set
        end
      end

      true
    end

    def set(ip_block : IPAddress, iata : Needles::IATA, priority : UInt8, ip_address : Socket::IPAddress)
      inactive_entry_cleanup

      @mutex.synchronize do
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
          entry_set = (entry_set - Set{entry_set.first})
          entry_set << Entry.new iata: iata, priority: priority, ipAddress: ip_address
          entries[ip_block] = entry_set
        else
          case percentage
          when .< 50_i32
            entry_set.each do |entry|
              next if iata == entry.iata

              entry_set = (entry_set - Set{entry})
              entry_set << Entry.new iata: iata, priority: priority, ipAddress: ip_address
              entries[ip_block] = entry_set

              return
            end
          else
            entry_set.each do |entry|
              next unless iata == entry.iata

              entry_set = (entry_set - Set{entry})
              entry_set << Entry.new iata: iata, priority: priority, ipAddress: ip_address
              entries[ip_block] = entry_set

              return
            end
          end
        end
      end
    end

    def to_tuple_ip_addresses : Array(Tuple(Needles::IATA, Socket::IPAddress))
      _entries = @mutex.synchronize { entries.dup }
      list = [] of Tuple(UInt8, Needles::IATA, Socket::IPAddress)

      _entries.each do |ip_block, entry_set|
        entry_set.each { |entry| list << Tuple.new entry.priority, entry.iata, entry.ipAddress }
      end

      list = list.sort { |a, b| a.first <=> b.first }

      list.map do |item|
        priority, iata, ip_address = item
        Tuple.new iata, ip_address
      end
    end

    struct Entry
      property iata : Needles::IATA
      property priority : UInt8
      property ipAddress : Socket::IPAddress
      property createdAt : Time

      def initialize(@iata : Needles::IATA, @priority : UInt8, @ipAddress : Socket::IPAddress)
        @createdAt = Time.local
      end
    end
  end
end
