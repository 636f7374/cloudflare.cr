module Cloudflare::Serialized
  module Export
    struct Radar
      include YAML::Serializable

      property ipBlocks : Array(Entry)
      property startingTime : Time
      property createdAt : Time

      def initialize(@ipBlocks : Array(Entry) = [] of Entry, @startingTime : Time = Time.local, @createdAt : Time = Time.local)
      end

      struct Entry
        include YAML::Serializable

        property ipBlock : String
        property edges : Hash(String, Int64)

        def initialize(@ipBlock : String = String.new, @edges : Hash(String, Int64) = Hash(String, Int64).new)
        end
      end
    end
  end
end
