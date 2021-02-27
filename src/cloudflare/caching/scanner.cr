module Cloudflare::Caching
  class Scanner
    getter options : Options
    getter entries : Hash(IPAddress, Set(Tuple(Needles::IATA, UInt8, Socket::IPAddress)))
    getter mutex : Mutex

    def initialize(@options : Options)
      @entries = Hash(IPAddress, Set(Tuple(Needles::IATA, UInt8, Socket::IPAddress))).new
      @mutex = Mutex.new :unchecked
    end

    def set(ip_range : IPAddress, iata : Needles::IATA, priority : UInt8, ip_address : Socket::IPAddress)
      @mutex.synchronize do
        entry = entries[ip_range] ||= Set(Tuple(Needles::IATA, UInt8, Socket::IPAddress)).new

        if entry.size < options.scanner.caching.ipAddressCapacityPerSubnet
          entry << Tuple.new iata, priority, ip_address
          entries[ip_range] = entry

          return
        end

        iata_count = entry.count { |item| iata == item.first }
        percentage = ((iata_count / entry.size) * 100_i32).round.to_i32

        case iata_count
        when .zero?
          entry = (entry - Set{entry.first})
          entry << Tuple.new iata, priority, ip_address
          entries[ip_range] = entry
        else
          case percentage
          when .< 50_i32
            entry.each do |item|
              next if iata == item.first

              entry = (entry - Set{entry.first})
              entry << Tuple.new iata, priority, ip_address
              entries[ip_range] = entry

              return
            end
          else
            entry.each do |item|
              next unless iata == item.first

              entry = (entry - Set{item})
              entry << Tuple.new iata, priority, ip_address
              entries[ip_range] = entry

              return
            end
          end
        end
      end
    end

    def to_tuple_ipaddresses : Array(Tuple(Needles::IATA, Socket::IPAddress))
      _entries = @mutex.synchronize { entries.dup }
      list = Set(Tuple(UInt8, Needles::IATA, Socket::IPAddress)).new

      _entries.each do |ip_range, entry|
        entry.each do |item|
          iata, priority, ip_address = item
          list << Tuple.new priority, iata, ip_address
        end
      end

      list = list.to_a.sort { |a, b| a.first <=> b.first }.to_set

      list.map do |item|
        priority, iata, ip_address = item
        Tuple.new iata, ip_address
      end
    end
  end
end
