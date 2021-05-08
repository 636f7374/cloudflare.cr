module Cloudflare
  enum ScanIpAddressType : UInt8
    Ipv4Only = 0_u8
    Ipv6Only = 1_u8
    Both     = 2_u8
  end

  enum ParallelFlag : UInt8
    Distributed = 0_u8
    SubProcess  = 1_u8
    Hybrid      = 2_u8
  end
end
