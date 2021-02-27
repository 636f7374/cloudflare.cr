module Cloudflare::Needles
  # References: https://www.cloudflarestatus.com/

  module Region
    enum Flag : UInt8
      Africa                    = 0_u8
      Asia                      = 1_u8
      Europe                    = 2_u8
      LatinAmerica_TheCaribbean = 3_u8
      MiddleEast                = 4_u8
      NorthAmerica              = 5_u8
      Oceania                   = 6_u8
    end

    Africa                    = (0_i32..16_i32).map { |index| IATA.from_value index }.to_set
    Asia                      = (17_i32..77_i32).map { |index| IATA.from_value index }.to_set
    Europe                    = (78_i32..125_i32).map { |index| IATA.from_value index }.to_set
    LatinAmerica_TheCaribbean = (126_i32..147_i32).map { |index| IATA.from_value index }.to_set
    MiddleEast                = (148_i32..159_i32).map { |index| IATA.from_value index }.to_set
    NorthAmerica              = (160_i32..207_i32).map { |index| IATA.from_value index }.to_set
    Oceania                   = (208..214_i32).map { |index| IATA.from_value index }.to_set

    def self.parse?(value : String)
      _flag = Flag.parse? value rescue nil
      return unless _flag

      case _flag
      in .africa?
        Africa
      in .asia?
        Asia
      in .europe?
        Europe
      in .latin_america_the_caribbean?
        LatinAmerica_TheCaribbean
      in .middle_east?
        MiddleEast
      in .north_america?
        NorthAmerica
      in .oceania?
        Oceania
      end
    end
  end
end
