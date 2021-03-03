module Cloudflare::Serialization
  struct Export
    include YAML::Serializable

    property subnets : Array(Entry)
    property startingTime : String
    property createdAt : String

    def initialize(@subnets : Array(Entry) = [] of Entry, @startingTime : String = Time.local.to_s, @createdAt : String = Time.local.to_s)
    end

    struct Entry
      include YAML::Serializable

      property ipRange : String
      property list : Hash(String, Int64)

      def initialize(@ipRange : String = String.new, @list : Hash(String, Int64) = Hash(String, Int64).new)
      end
    end
  end
end
