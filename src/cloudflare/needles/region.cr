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

    Africa                    = (0_i32..21_i32).map { |index| IATA.from_value index }.to_set
    Asia                      = (22_i32..102_i32).map { |index| IATA.from_value index }.to_set
    Europe                    = (103_i32..156_i32).map { |index| IATA.from_value index }.to_set
    LatinAmerica_TheCaribbean = (157_i32..204_i32).map { |index| IATA.from_value index }.to_set
    MiddleEast                = (205_i32..225_i32).map { |index| IATA.from_value index }.to_set
    NorthAmerica              = (226_i32..272_i32).map { |index| IATA.from_value index }.to_set
    Oceania                   = (273..283_i32).map { |index| IATA.from_value index }.to_set

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
