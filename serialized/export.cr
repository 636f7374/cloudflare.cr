module Cloudflare::Serialized
  struct Export
    include YAML::Serializable

    property blocks : Array(Entry)
    property startingTime : Time
    property createdAt : Time

    def initialize(@blocks : Array(Entry) = [] of Entry, @startingTime : Time = Time.local, @createdAt : Time = Time.local)
    end

    struct Entry
      include YAML::Serializable

      property block : String
      property edges : Hash(String, Int64)

      def initialize(@block : String = String.new, @edges : Hash(String, Int64) = Hash(String, Int64).new)
      end
    end
  end
end
