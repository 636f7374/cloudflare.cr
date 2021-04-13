class Cloudflare::Scanner
  struct Task
    struct Block
      property ipBlock : IPAddress
      property expects : Array(Expect)

      def initialize(@ipBlock : IPAddress, @expects : Array(Expect) = [] of Expect)
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
