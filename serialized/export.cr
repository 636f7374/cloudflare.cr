module Cloudflare::Serialized
  struct Export
    include YAML::Serializable

    property subnets : Array(Entry)
    property startingTime : Time
    property createdAt : Time

    def initialize(@subnets : Array(Entry) = [] of Entry, @startingTime : Time = Time.local, @createdAt : Time = Time.local)
    end

    struct Entry
      include YAML::Serializable

      property subnet : String
      property edges : Hash(String, Int64)

      def initialize(@subnet : String = String.new, @edges : Hash(String, Int64) = Hash(String, Int64).new)
      end
    end
  end
end
