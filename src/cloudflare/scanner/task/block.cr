class Cloudflare::Scanner
  struct Task
    struct Block
      property ipRange : IPAddress
      property expects : Array(Expect)

      def initialize(@ipRange : IPAddress, @expects : Array(Expect) = [] of Expect)
      end

      struct Expect
        property iata : Needles::IATA
        property priority : UInt8

        def initialize(@iata : Needles::IATA, @priority : UInt8 = 0_u8)
        end
      end
    end
  end
end
