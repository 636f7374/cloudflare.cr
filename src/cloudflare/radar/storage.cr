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

    def each(&block : String, Entry ->)
      @mutex.synchronize { entries.each { |_block, edges| yield _block, edges } }
    end

    def exclude(options : Options)
      @mutex.synchronize do
        options.radar.excludes.each do |needles|
          entries.each do |name, entry|
            case needles.size
            when .zero?
            when 1_i32
              needles_all = needles.map do |needle|
                entry.edges.all? { |tuple| needle == tuple.first }
              end

              entries.delete name if needles_all.all?
            else
              equal_size = needles.size == entry.edges.size
              includes_map = needles.map { |needle| entry.edges[needle]? }
              entries.delete name if equal_size && includes_map.all?
            end
          end
        end
      end
    end

    def set(block : IPAddress, edge : Needles::Edge) : Bool
      @mutex.synchronize do
        text_block = String.build { |io| io << block.address << "/" << block.prefix }
        entry = entries[text_block] ||= Entry.new
        visits = entry.edges[edge] ||= 0_i64
        entry.edges[edge] = visits += 1_i32
        entries[text_block] = entry
      end

      true
    end

    struct Entry
      property edges : Hash(Needles::Edge, Int64)

      def initialize
        @edges = Hash(Needles::Edge, Int64).new
      end
    end
  end
end
