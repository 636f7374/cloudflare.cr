class Cloudflare::Radar
  class Storage
    getter entries : Hash(String, Entry)
    getter mutex : Mutex

    def initialize
      @entries = Hash(String, Entry).new
      @mutex = Mutex.new :unchecked
    end

    def size : Int32
      @mutex.synchronize { entries.size }
    end

    def clear_if_only_needles(options : Options)
      @mutex.synchronize do
        options.radar.clearIfOnlyNeedles.each do |needles|
          entries.each do |name, entry|
            case needles.size
            when .zero?
            when 1_i32
              needles_all = needles.map do |needle|
                entry.list.all? { |tuple| needle == tuple.first }
              end

              entries.delete name if needles_all.all?
            else
              equal_size = needles.size == entry.list.size
              includes_map = needles.map { |needle| entry.list[needle]? }
              entries.delete name if equal_size && includes_map.all?
            end
          end
        end
      end
    end

    def each(&block : Tuple(String, Entry) ->)
      @mutex.synchronize { entries.each { |entry| yield entry } }
    end

    def set(ip_range : IPAddress, edge : Needles::Edge) : Bool
      @mutex.synchronize do
        string_ip_range = String.build { |io| io << ip_range.address << "/" << ip_range.prefix }
        entry = entries[string_ip_range] ||= Entry.new
        visits = entry.list[edge] ||= 0_i64
        entry.list[edge] = visits += 1_i32
        entries[string_ip_range] = entry
      end

      true
    end

    struct Entry
      property list : Hash(Needles::Edge, Int64)

      def initialize
        @list = Hash(Needles::Edge, Int64).new
      end
    end
  end
end
