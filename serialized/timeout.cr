module Cloudflare::Serialized
  struct TimeOut
    include YAML::Serializable

    property read : Int32
    property write : Int32
    property connect : Int32

    def initialize
      @read = 2_i32
      @write = 2_i32
      @connect = 2_i32
    end

    def to_callee_timeout : Radar::Callee::TimeOut
      timeout = Radar::Callee::TimeOut.new

      timeout.read = read
      timeout.write = write
      timeout.connect = connect

      timeout
    end

    def unwrap : Cloudflare::TimeOut
      timeout = Cloudflare::TimeOut.new

      timeout.read = read
      timeout.write = write
      timeout.connect = connect

      timeout
    end
  end
end
