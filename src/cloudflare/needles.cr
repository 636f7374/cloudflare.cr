module Cloudflare::Needles
  # References: https://www.cloudflarestatus.com/

  enum Flag : UInt8
    IATA   = 0_u8
    Edge   = 1_u8
    Region = 2_u8
  end

  enum Edge : Int32
    Accra_Ghana                    =   0_i32
    Algiers_Algeria                =   1_i32
    Antananarivo_Madagascar        =   2_i32
    CapeTown_SouthAfrica           =   3_i32
    Casablanca_Morocco             =   4_i32
    Dakar_Senegal                  =   5_i32
    DarEsSalaam_Tanzania           =   6_i32
    DjiboutiCity_Djibouti          =   7_i32
    Durban_SouthAfrica             =   8_i32
    Gaborone_Botswana              =   9_i32
    Harare_Zimbabwe                =  10_i32
    Johannesburg_SouthAfrica       =  11_i32
    Kigali_Rwanda                  =  12_i32
    Lagos_Nigeria                  =  13_i32
    Luanda_Angola                  =  14_i32
    Maputo_Mozambique              =  15_i32
    Mombasa_Kenya                  =  16_i32
    Nairobi_Kenya                  =  17_i32
    Ouagadougou_BurkinaFaso        =  18_i32
    PortLouis_Mauritius            =  19_i32
    Réunion_France                 =  20_i32
    Tunis_Tunisia                  =  21_i32
    Ahmedabad_India                =  22_i32
    Almaty_Kazakhstan              =  23_i32
    Anqing_China                   =  24_i32
    Bangalore_India                =  25_i32
    Bangkok_Thailand               =  26_i32
    BandarSeriBegawan_Brunei       =  27_i32
    Baoji_China                    =  28_i32
    Bhubaneswar_India              =  29_i32
    Cebu_Philippines               =  30_i32
    Chandigarh_IN                  =  31_i32
    Changde_China                  =  32_i32
    Chennai_India                  =  33_i32
    ChiangMai_Thailand             =  34_i32
    Chittagong_Bangladesh          =  35_i32
    Colombo_SriLanka               =  36_i32
    Dhaka_Bangladesh               =  37_i32
    Foshan_China                   =  38_i32
    Fuzhou_China                   =  39_i32
    Guangzhou_China                =  40_i32
    Haikou_China                   =  41_i32
    Hanoi_Vietnam                  =  42_i32
    Hengshui_China                 =  43_i32
    HoChiMinhCity_Vietnam          =  44_i32
    HongKong                       =  45_i32
    Hyderabad_India                =  46_i32
    Islamabad_Pakistan             =  47_i32
    Jakarta_Indonesia              =  48_i32
    Jashore_Bangladesh             =  49_i32
    Jinan_China                    =  50_i32
    Jinhua_China                   =  51_i32
    JohorBahru_Malaysia            =  52_i32
    Kanpur_India                   =  53_i32
    KaohsiungCity                  =  54_i32
    Karachi_Pakistan               =  55_i32
    Kathmandu_Nepal                =  56_i32
    Khabarovsk_Russia              =  57_i32
    Kolkata_India                  =  58_i32
    Krasnoyarsk_Russia             =  59_i32
    KualaLumpur_Malaysia           =  60_i32
    Lahore_Pakistan                =  61_i32
    Langfang_China                 =  62_i32
    Lanzhou_China                  =  63_i32
    Luoyang_China                  =  64_i32
    Macau                          =  65_i32
    Malé_Maldives                  =  66_i32
    Mandalay_Myanmar               =  67_i32
    Manila_Philippines             =  68_i32
    Mumbai_India                   =  69_i32
    Nagpur_India                   =  70_i32
    Naha_Japan                     =  71_i32
    NewDelhi_India                 =  72_i32
    Osaka_Japan                    =  73_i32
    Patna_India                    =  74_i32
    PhnomPenh_Cambodia             =  75_i32
    Qingdao_China                  =  76_i32
    Seoul_SouthKorea               =  77_i32
    Shanghai_China                 =  78_i32
    Singapore_Singapore            =  79_i32
    SuratThani_Thailand            =  80_i32
    Taipei                         =  81_i32
    Tashkent_Uzbekistan            =  82_i32
    Thimphu_Bhutan                 =  83_i32
    Tianjin_China                  =  84_i32
    Tokyo_Japan                    =  85_i32
    Ulaanbaatar_Mongolia           =  86_i32
    Vientiane_Laos                 =  87_i32
    Wuxi_China                     =  88_i32
    Xining_China                   =  89_i32
    Xinyu_China                    =  90_i32
    Yangon_Myanmar                 =  91_i32
    Yerevan_Armenia                =  92_i32
    Yogyakarta_Indonesia           =  93_i32
    Zhengzhou_China                =  94_i32
    Changchun_China                =  95_i32
    Nanning_China                  =  96_i32
    Xiaogan_China                  =  97_i32
    Yangzhou_China                 =  98_i32
    Zhongshan_China                =  99_i32
    CagayandeOro_Philippines       = 100_i32
    Changsha_China                 = 101_i32
    Datong_China                   = 102_i32
    Amsterdam_Netherlands          = 103_i32
    Athens_Greece                  = 104_i32
    Barcelona_Spain                = 105_i32
    Belgrade_Serbia                = 106_i32
    Berlin_Germany                 = 107_i32
    Bratislava_Slovakia            = 108_i32
    Brussels_Belgium               = 109_i32
    Bucharest_Romania              = 110_i32
    Budapest_Hungary               = 111_i32
    Chișinău_Moldova               = 112_i32
    Copenhagen_Denmark             = 113_i32
    Cork_Ireland                   = 114_i32
    Dublin_Ireland                 = 115_i32
    Düsseldorf_Germany             = 116_i32
    Edinburgh_UnitedKingdom        = 117_i32
    Frankfurt_Germany              = 118_i32
    Geneva_Switzerland             = 119_i32
    Gothenburg_Sweden              = 120_i32
    Hamburg_Germany                = 121_i32
    Helsinki_Finland               = 122_i32
    Istanbul_Turkey                = 123_i32
    Kyiv_Ukraine                   = 124_i32
    Lisbon_Portugal                = 125_i32
    London_UnitedKingdom           = 126_i32
    LuxembourgCity_Luxembourg      = 127_i32
    Madrid_Spain                   = 128_i32
    Manchester_UnitedKingdom       = 129_i32
    Marseille_France               = 130_i32
    Milan_Italy                    = 131_i32
    Minsk_Belarus                  = 132_i32
    Moscow_Russia                  = 133_i32
    Munich_Germany                 = 134_i32
    Nicosia_Cyprus                 = 135_i32
    Oslo_Norway                    = 136_i32
    Palermo_Italy                  = 137_i32
    Paris_France                   = 138_i32
    Prague_CzechRepublic           = 139_i32
    Reykjavík_Iceland              = 140_i32
    Riga_Latvia                    = 141_i32
    Rome_Italy                     = 142_i32
    SaintPetersburg_Russia         = 143_i32
    Sofia_Bulgaria                 = 144_i32
    Stockholm_Sweden               = 145_i32
    Tallinn_Estonia                = 146_i32
    Tbilisi_Georgia                = 147_i32
    Thessaloniki_Greece            = 148_i32
    Tirana_Albania                 = 149_i32
    Vienna_Austria                 = 150_i32
    Vilnius_Lithuania              = 151_i32
    Warsaw_Poland                  = 152_i32
    Yekaterinburg_Russia           = 153_i32
    Zagreb_Croatia                 = 154_i32
    Zürich_Switzerland             = 155_i32
    Tver_RussianFederation         = 156_i32
    Americana_Brazil               = 157_i32
    Arica_Chile                    = 158_i32
    Asunción_Paraguay              = 159_i32
    Belém_Brazil                   = 160_i32
    BeloHorizonte_Brazil           = 161_i32
    Blumenau_Brazil                = 162_i32
    Bogotá_Colombia                = 163_i32
    Brasilia_Brazil                = 164_i32
    BuenosAires_Argentina          = 165_i32
    Caçador_Brazil                 = 166_i32
    Campinas_Brazil                = 167_i32
    Concepción_Chile               = 168_i32
    Córdoba_Argentina              = 169_i32
    Cuiabá_Brazil                  = 170_i32
    Curitiba_Brazil                = 171_i32
    Florianopolis_Brazil           = 172_i32
    Fortaleza_Brazil               = 173_i32
    Georgetown_Guyana              = 174_i32
    Goiânia_Brazil                 = 175_i32
    GuatemalaCity_Guatemala        = 176_i32
    Guayaquil_Ecuador              = 177_i32
    Itajaí_Brazil                  = 178_i32
    Joinville_Brazil               = 179_i32
    JuazeirodoNorte_Brazil         = 180_i32
    Lima_Peru                      = 181_i32
    Manaus_Brazil                  = 182_i32
    Medellín_Colombia              = 183_i32
    Neuquén_Argentina              = 184_i32
    PanamaCity_Panama              = 185_i32
    Paramaribo_Suriname            = 186_i32
    PortoAlegre_Brazil             = 187_i32
    Port_Au_Prince_Haiti           = 188_i32
    Quito_Ecuador                  = 189_i32
    RibeiraoPreto_Brazil           = 190_i32
    RiodeJaneiro_Brazil            = 191_i32
    Salvador_Brazil                = 192_i32
    SanJosé_CostaRica              = 193_i32
    Santiago_Chile                 = 194_i32
    SãoJosédoRioPreto_Brazil       = 195_i32
    SãoPaulo_Brazil                = 196_i32
    Sorocaba_Brazil                = 197_i32
    StGeorges_Grenada              = 198_i32
    Tegucigalpa_Honduras           = 199_i32
    Timbó_Brazil                   = 200_i32
    Uberlândia_Brazil              = 201_i32
    Willemstad_Curaçao             = 202_i32
    SantoDomingo_DominicanRepublic = 203_i32
    Nashville_UnitedStates         = 204_i32
    Amman_Jordan                   = 205_i32
    Astara_Azerbaijan              = 206_i32
    Baghdad_Iraq                   = 207_i32
    Baku_Azerbaijan                = 208_i32
    Basra_Iraq                     = 209_i32
    Beirut_Lebanon                 = 210_i32
    Dammam_SaudiArabia             = 211_i32
    Doha_Qatar                     = 212_i32
    Dubai_UnitedArabEmirates       = 213_i32
    Erbil_Iraq                     = 214_i32
    Haifa_Israel                   = 215_i32
    Jeddah_SaudiArabia             = 216_i32
    KuwaitCity_Kuwait              = 217_i32
    Manama_Bahrain                 = 218_i32
    Muscat_Oman                    = 219_i32
    Najaf_Iraq                     = 220_i32
    Nasiriyah_Iraq                 = 221_i32
    Ramallah                       = 222_i32
    Riyadh_SaudiArabia             = 223_i32
    Sulaymaniyah_Iraq              = 224_i32
    TelAviv_Israel                 = 225_i32
    Ashburn_VA_UnitedStates        = 226_i32
    Atlanta_GA_UnitedStates        = 227_i32
    Boston_MA_UnitedStates         = 228_i32
    Buffalo_NY_UnitedStates        = 229_i32
    Calgary_AB_Canada              = 230_i32
    Charlotte_NC_UnitedStates      = 231_i32
    Chicago_IL_UnitedStates        = 232_i32
    Columbus_OH_UnitedStates       = 233_i32
    Dallas_TX_UnitedStates         = 234_i32
    Denver_CO_UnitedStates         = 235_i32
    Detroit_MI_UnitedStates        = 236_i32
    Honolulu_HI_UnitedStates       = 237_i32
    Houston_TX_UnitedStates        = 238_i32
    Indianapolis_IN_UnitedStates   = 239_i32
    Jacksonville_FL_UnitedStates   = 240_i32
    KansasCity_MO_UnitedStates     = 241_i32
    LasVegas_NV_UnitedStates       = 242_i32
    LosAngeles_CA_UnitedStates     = 243_i32
    McAllen_TX_UnitedStates        = 244_i32
    Memphis_TN_UnitedStates        = 245_i32
    MexicoCity_Mexico              = 246_i32
    Miami_FL_UnitedStates          = 247_i32
    Minneapolis_MN_UnitedStates    = 248_i32
    Montgomery_AL_UnitedStates     = 249_i32
    Montréal_QC_Canada             = 250_i32
    Newark_NJ_UnitedStates         = 251_i32
    Norfolk_VA_UnitedStates        = 252_i32
    Omaha_NE_UnitedStates          = 253_i32
    Ottawa_Canada                  = 254_i32
    Philadelphia_UnitedStates      = 255_i32
    Phoenix_AZ_UnitedStates        = 256_i32
    Pittsburgh_PA_UnitedStates     = 257_i32
    Portland_OR_UnitedStates       = 258_i32
    Queretaro_MX_Mexico            = 259_i32
    Richmond_VA_UnitedStates       = 260_i32
    Sacramento_CA_UnitedStates     = 261_i32
    SaltLakeCity_UT_UnitedStates   = 262_i32
    SanDiego_CA_UnitedStates       = 263_i32
    SanJose_CA_UnitedStates        = 264_i32
    Saskatoon_SK_Canada            = 265_i32
    Seattle_WA_UnitedStates        = 266_i32
    StLouis_MO_UnitedStates        = 267_i32
    Tallahassee_FL_UnitedStates    = 268_i32
    Tampa_FL_UnitedStates          = 269_i32
    Toronto_ON_Canada              = 270_i32
    Vancouver_BC_Canada            = 271_i32
    Winnipeg_MB_Canada             = 272_i32
    Adelaide_SA_Australia          = 273_i32
    Auckland_NewZealand            = 274_i32
    Brisbane_QLD_Australia         = 275_i32
    Canberra_ACT_Australia         = 276_i32
    Christchurch_NewZealand        = 277_i32
    Hagatna_Guam                   = 278_i32
    Hobart_Australia               = 279_i32
    Melbourne_VIC_Australia        = 280_i32
    Noumea_NewCaledonia            = 281_i32
    Perth_WA_Australia             = 282_i32
    Sydney_NSW_Australia           = 283_i32

    def to_iata? : IATA?
      IATA.from_value? to_i
    end

    def self.parse?(iata : IATA) : Edge?
      Edge.from_value? iata.to_i rescue nil
    end
  end

  enum IATA : Int32
    ACC =   0_i32
    ALG =   1_i32
    TNR =   2_i32
    CPT =   3_i32
    CMN =   4_i32
    DKR =   5_i32
    DAR =   6_i32
    JIB =   7_i32
    DUR =   8_i32
    GBE =   9_i32
    HRE =  10_i32
    JNB =  11_i32
    KGL =  12_i32
    LOS =  13_i32
    LAD =  14_i32
    MPM =  15_i32
    MBA =  16_i32
    NBO =  17_i32
    OUA =  18_i32
    MRU =  19_i32
    RUN =  20_i32
    TUN =  21_i32
    AMD =  22_i32
    ALA =  23_i32
    AQG =  24_i32
    BLR =  25_i32
    BKK =  26_i32
    BWN =  27_i32
    XIY =  28_i32
    BBI =  29_i32
    CEB =  30_i32
    IXC =  31_i32
    CGD =  32_i32
    MAA =  33_i32
    CNX =  34_i32
    CGP =  35_i32
    CMB =  36_i32
    DAC =  37_i32
    FUO =  38_i32
    FOC =  39_i32
    CAN =  40_i32
    HAK =  41_i32
    HAN =  42_i32
    SJW =  43_i32
    SGN =  44_i32
    HKG =  45_i32
    HYD =  46_i32
    ISB =  47_i32
    CGK =  48_i32
    JSR =  49_i32
    TNA =  50_i32
    HGH =  51_i32
    JHB =  52_i32
    KNU =  53_i32
    KHH =  54_i32
    KHI =  55_i32
    KTM =  56_i32
    KHV =  57_i32
    CCU =  58_i32
    KJA =  59_i32
    KUL =  60_i32
    LHE =  61_i32
    PKX =  62_i32
    LHW =  63_i32
    LYA =  64_i32
    MFM =  65_i32
    MLE =  66_i32
    MDL =  67_i32
    MNL =  68_i32
    BOM =  69_i32
    NAG =  70_i32
    OKA =  71_i32
    DEL =  72_i32
    KIX =  73_i32
    PAT =  74_i32
    PNH =  75_i32
    TAO =  76_i32
    ICN =  77_i32
    SHA =  78_i32
    SIN =  79_i32
    URT =  80_i32
    TPE =  81_i32
    TAS =  82_i32
    PBH =  83_i32
    TSN =  84_i32
    NRT =  85_i32
    ULN =  86_i32
    VTE =  87_i32
    WUX =  88_i32
    XNN =  89_i32
    KHN =  90_i32
    RGN =  91_i32
    EVN =  92_i32
    JOG =  93_i32
    CGO =  94_i32
    CGQ =  95_i32
    NNG =  96_i32
    WUH =  97_i32
    YTY =  98_i32
    ZGN =  99_i32
    CGY = 100_i32
    CSX = 101_i32
    TYN = 102_i32
    AMS = 103_i32
    ATH = 104_i32
    BCN = 105_i32
    BEG = 106_i32
    TXL = 107_i32
    BTS = 108_i32
    BRU = 109_i32
    OTP = 110_i32
    BUD = 111_i32
    KIV = 112_i32
    CPH = 113_i32
    ORK = 114_i32
    DUB = 115_i32
    DUS = 116_i32
    EDI = 117_i32
    FRA = 118_i32
    GVA = 119_i32
    GOT = 120_i32
    HAM = 121_i32
    HEL = 122_i32
    IST = 123_i32
    KBP = 124_i32
    LIS = 125_i32
    LHR = 126_i32
    LUX = 127_i32
    MAD = 128_i32
    MAN = 129_i32
    MRS = 130_i32
    MXP = 131_i32
    MSQ = 132_i32
    DME = 133_i32
    MUC = 134_i32
    LCA = 135_i32
    OSL = 136_i32
    PMO = 137_i32
    CDG = 138_i32
    PRG = 139_i32
    KEF = 140_i32
    RIX = 141_i32
    FCO = 142_i32
    LED = 143_i32
    SOF = 144_i32
    ARN = 145_i32
    TLL = 146_i32
    TBS = 147_i32
    SKG = 148_i32
    TIA = 149_i32
    VIE = 150_i32
    VNO = 151_i32
    WAW = 152_i32
    SVX = 153_i32
    ZAG = 154_i32
    ZRH = 155_i32
    KLD = 156_i32
    QWJ = 157_i32
    ARI = 158_i32
    ASU = 159_i32
    BEL = 160_i32
    CNF = 161_i32
    BNU = 162_i32
    BOG = 163_i32
    BSB = 164_i32
    EZE = 165_i32
    CFC = 166_i32
    VCP = 167_i32
    CCP = 168_i32
    COR = 169_i32
    CGB = 170_i32
    CWB = 171_i32
    FLN = 172_i32
    FOR = 173_i32
    GEO = 174_i32
    GYN = 175_i32
    GUA = 176_i32
    GYE = 177_i32
    ITJ = 178_i32
    JOI = 179_i32
    JDO = 180_i32
    LIM = 181_i32
    MAO = 182_i32
    MDE = 183_i32
    NQN = 184_i32
    PTY = 185_i32
    PBM = 186_i32
    POA = 187_i32
    PAP = 188_i32
    UIO = 189_i32
    RAO = 190_i32
    GIG = 191_i32
    SSA = 192_i32
    SJO = 193_i32
    SCL = 194_i32
    SJP = 195_i32
    GRU = 196_i32
    SOD = 197_i32
    GND = 198_i32
    TGU = 199_i32
    NVT = 200_i32
    UDI = 201_i32
    CUR = 202_i32
    SDQ = 203_i32
    BNA = 204_i32
    AMM = 205_i32
    LLK = 206_i32
    BGW = 207_i32
    GYD = 208_i32
    BSR = 209_i32
    BEY = 210_i32
    DMM = 211_i32
    DOH = 212_i32
    DXB = 213_i32
    EBL = 214_i32
    HFA = 215_i32
    JED = 216_i32
    KWI = 217_i32
    BAH = 218_i32
    MCT = 219_i32
    NJF = 220_i32
    XNH = 221_i32
    ZDM = 222_i32
    RUH = 223_i32
    ISU = 224_i32
    TLV = 225_i32
    IAD = 226_i32
    ATL = 227_i32
    BOS = 228_i32
    BUF = 229_i32
    YYC = 230_i32
    CLT = 231_i32
    ORD = 232_i32
    CMH = 233_i32
    DFW = 234_i32
    DEN = 235_i32
    DTW = 236_i32
    HNL = 237_i32
    IAH = 238_i32
    IND = 239_i32
    JAX = 240_i32
    MCI = 241_i32
    LAS = 242_i32
    LAX = 243_i32
    MFE = 244_i32
    MEM = 245_i32
    MEX = 246_i32
    MIA = 247_i32
    MSP = 248_i32
    MGM = 249_i32
    YUL = 250_i32
    EWR = 251_i32
    ORF = 252_i32
    OMA = 253_i32
    YOW = 254_i32
    PHL = 255_i32
    PHX = 256_i32
    PIT = 257_i32
    PDX = 258_i32
    QRO = 259_i32
    RIC = 260_i32
    SMF = 261_i32
    SLC = 262_i32
    SAN = 263_i32
    SJC = 264_i32
    YXE = 265_i32
    SEA = 266_i32
    STL = 267_i32
    TLH = 268_i32
    TPA = 269_i32
    YYZ = 270_i32
    YVR = 271_i32
    YWG = 272_i32
    ADL = 273_i32
    AKL = 274_i32
    BNE = 275_i32
    CBR = 276_i32
    CHC = 277_i32
    GUM = 278_i32
    HBA = 279_i32
    MEL = 280_i32
    NOU = 281_i32
    PER = 282_i32
    SYD = 283_i32

    def to_edge? : Edge?
      Edge.from_value? to_i
    end

    def self.parse?(edge : Edge) : IATA?
      IATA.from_value? edge.to_i rescue nil
    end
  end
end

require "./needles/*"
