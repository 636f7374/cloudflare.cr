module Cloudflare::Subnet
  # Ipv4: AS13335, AS209242, AS132892, AS139242, AS202623, AS395747, AS203898
  # |_Empty: AS14789, AS133877
  # Ipv6: AS13335, AS209242, AS132892, AS139242, AS394536, AS202623, AS395747, AS203898
  # |_Empty: AS14789, AS133877

  Ipv4 = Set{
    # References: https://ipinfo.io/AS13335
    # AS13335 - Cloudflare, Inc.

    IPAddress.new(addr: "1.0.0.0/24"), IPAddress.new(addr: "1.1.1.0/24"), IPAddress.new(addr: "103.21.244.0/24"),
    IPAddress.new(addr: "103.22.200.0/23"), IPAddress.new(addr: "103.22.203.0/24"), IPAddress.new(addr: "103.81.228.0/24"),
    IPAddress.new(addr: "104.16.0.0/12"), IPAddress.new(addr: "108.162.192.0/20"), IPAddress.new(addr: "108.162.208.0/24"),
    IPAddress.new(addr: "108.162.210.0/23"), IPAddress.new(addr: "108.162.212.0/22"), IPAddress.new(addr: "108.162.216.0/22"),
    IPAddress.new(addr: "108.162.220.0/23"), IPAddress.new(addr: "108.162.223.0/24"), IPAddress.new(addr: "108.162.228.0/23"),
    IPAddress.new(addr: "108.162.235.0/24"), IPAddress.new(addr: "108.162.236.0/22"), IPAddress.new(addr: "108.162.240.0/21"),
    IPAddress.new(addr: "108.162.248.0/23"), IPAddress.new(addr: "108.162.250.0/24"), IPAddress.new(addr: "108.162.255.0/24"),
    IPAddress.new(addr: "141.101.104.0/22"), IPAddress.new(addr: "141.101.108.0/23"), IPAddress.new(addr: "141.101.110.0/24"),
    IPAddress.new(addr: "141.101.112.0/20"), IPAddress.new(addr: "141.101.64.0/21"), IPAddress.new(addr: "141.101.72.0/22"),
    IPAddress.new(addr: "141.101.76.0/23"), IPAddress.new(addr: "141.101.82.0/23"), IPAddress.new(addr: "141.101.84.0/23"),
    IPAddress.new(addr: "141.101.94.0/23"), IPAddress.new(addr: "141.101.96.0/21"), IPAddress.new(addr: "162.158.0.0/19"),
    IPAddress.new(addr: "162.158.112.0/23"), IPAddress.new(addr: "162.158.114.0/24"), IPAddress.new(addr: "162.158.116.0/22"),
    IPAddress.new(addr: "162.158.120.0/21"), IPAddress.new(addr: "162.158.128.0/22"), IPAddress.new(addr: "162.158.132.0/23"),
    IPAddress.new(addr: "162.158.134.0/24"), IPAddress.new(addr: "162.158.136.0/21"), IPAddress.new(addr: "162.158.144.0/22"),
    IPAddress.new(addr: "162.158.148.0/23"), IPAddress.new(addr: "162.158.151.0/24"), IPAddress.new(addr: "162.158.152.0/21"),
    IPAddress.new(addr: "162.158.160.0/19"), IPAddress.new(addr: "162.158.192.0/18"), IPAddress.new(addr: "162.158.32.0/22"),
    IPAddress.new(addr: "162.158.36.0/23"), IPAddress.new(addr: "162.158.38.0/24"), IPAddress.new(addr: "162.158.40.0/21"),
    IPAddress.new(addr: "162.158.48.0/20"), IPAddress.new(addr: "162.158.72.0/21"), IPAddress.new(addr: "162.158.81.0/24"),
    IPAddress.new(addr: "162.158.82.0/23"), IPAddress.new(addr: "162.158.84.0/22"), IPAddress.new(addr: "162.158.88.0/21"),
    IPAddress.new(addr: "162.158.96.0/20"), IPAddress.new(addr: "162.159.0.0/18"), IPAddress.new(addr: "162.159.128.0/17"),
    IPAddress.new(addr: "162.159.64.0/20"), IPAddress.new(addr: "162.247.243.0/24"), IPAddress.new(addr: "162.251.82.0/24"),
    IPAddress.new(addr: "172.64.0.0/15"), IPAddress.new(addr: "172.67.0.0/16"), IPAddress.new(addr: "172.68.0.0/18"),
    IPAddress.new(addr: "172.68.112.0/21"), IPAddress.new(addr: "172.68.120.0/23"), IPAddress.new(addr: "172.68.124.0/23"),
    IPAddress.new(addr: "172.68.128.0/20"), IPAddress.new(addr: "172.68.144.0/21"), IPAddress.new(addr: "172.68.152.0/23"),
    IPAddress.new(addr: "172.68.160.0/19"), IPAddress.new(addr: "172.68.196.0/22"), IPAddress.new(addr: "172.68.200.0/23"),
    IPAddress.new(addr: "172.68.204.0/22"), IPAddress.new(addr: "172.68.208.0/21"), IPAddress.new(addr: "172.68.220.0/23"),
    IPAddress.new(addr: "172.68.224.0/19"), IPAddress.new(addr: "172.68.64.0/21"), IPAddress.new(addr: "172.68.72.0/23"),
    IPAddress.new(addr: "172.68.76.0/22"), IPAddress.new(addr: "172.68.80.0/21"), IPAddress.new(addr: "172.68.88.0/23"),
    IPAddress.new(addr: "172.68.90.0/24"), IPAddress.new(addr: "172.68.92.0/22"), IPAddress.new(addr: "172.68.96.0/20"),
    IPAddress.new(addr: "172.69.0.0/21"), IPAddress.new(addr: "172.69.100.0/24"), IPAddress.new(addr: "172.69.104.0/21"),
    IPAddress.new(addr: "172.69.112.0/21"), IPAddress.new(addr: "172.69.12.0/24"), IPAddress.new(addr: "172.69.124.0/22"),
    IPAddress.new(addr: "172.69.128.0/19"), IPAddress.new(addr: "172.69.14.0/23"), IPAddress.new(addr: "172.69.16.0/24"),
    IPAddress.new(addr: "172.69.160.0/20"), IPAddress.new(addr: "172.69.176.0/22"), IPAddress.new(addr: "172.69.18.0/23"),
    IPAddress.new(addr: "172.69.180.0/24"), IPAddress.new(addr: "172.69.184.0/21"), IPAddress.new(addr: "172.69.192.0/22"),
    IPAddress.new(addr: "172.69.196.0/24"), IPAddress.new(addr: "172.69.20.0/22"), IPAddress.new(addr: "172.69.200.0/21"),
    IPAddress.new(addr: "172.69.208.0/24"), IPAddress.new(addr: "172.69.212.0/22"), IPAddress.new(addr: "172.69.216.0/21"),
    IPAddress.new(addr: "172.69.224.0/20"), IPAddress.new(addr: "172.69.240.0/21"), IPAddress.new(addr: "172.69.248.0/24"),
    IPAddress.new(addr: "172.69.252.0/22"), IPAddress.new(addr: "172.69.32.0/21"), IPAddress.new(addr: "172.69.40.0/22"),
    IPAddress.new(addr: "172.69.44.0/23"), IPAddress.new(addr: "172.69.46.0/24"), IPAddress.new(addr: "172.69.48.0/20"),
    IPAddress.new(addr: "172.69.64.0/20"), IPAddress.new(addr: "172.69.8.0/22"), IPAddress.new(addr: "172.69.80.0/22"),
    IPAddress.new(addr: "172.69.88.0/21"), IPAddress.new(addr: "172.69.96.0/22"), IPAddress.new(addr: "173.245.48.0/23"),
    IPAddress.new(addr: "173.245.52.0/24"), IPAddress.new(addr: "173.245.54.0/24"), IPAddress.new(addr: "173.245.58.0/23"),
    IPAddress.new(addr: "173.245.63.0/24"), IPAddress.new(addr: "188.114.104.0/24"), IPAddress.new(addr: "188.114.106.0/23"),
    IPAddress.new(addr: "188.114.108.0/22"), IPAddress.new(addr: "188.114.96.0/21"), IPAddress.new(addr: "190.93.240.0/20"),
    IPAddress.new(addr: "197.234.240.0/22"), IPAddress.new(addr: "198.217.251.0/24"), IPAddress.new(addr: "198.41.128.0/23"),
    IPAddress.new(addr: "198.41.192.0/20"), IPAddress.new(addr: "198.41.208.0/23"), IPAddress.new(addr: "198.41.211.0/24"),
    IPAddress.new(addr: "198.41.212.0/24"), IPAddress.new(addr: "198.41.214.0/23"), IPAddress.new(addr: "198.41.220.0/22"),
    IPAddress.new(addr: "198.41.224.0/21"), IPAddress.new(addr: "198.41.232.0/23"), IPAddress.new(addr: "198.41.235.0/24"),
    IPAddress.new(addr: "198.41.236.0/22"), IPAddress.new(addr: "198.41.240.0/23"), IPAddress.new(addr: "198.41.242.0/24"),
    IPAddress.new(addr: "199.27.132.0/24"), IPAddress.new(addr: "23.227.38.0/23"), IPAddress.new(addr: "64.179.227.0/24"),
    IPAddress.new(addr: "64.179.228.0/24"), IPAddress.new(addr: "64.68.192.0/24"), IPAddress.new(addr: "65.110.63.0/24"),
    IPAddress.new(addr: "66.235.200.0/24"), IPAddress.new(addr: "68.67.65.0/24"), IPAddress.new(addr: "8.10.148.0/24"),
    IPAddress.new(addr: "8.14.199.0/24"), IPAddress.new(addr: "8.14.201.0/24"), IPAddress.new(addr: "8.14.202.0/23"),
    IPAddress.new(addr: "8.14.204.0/24"), IPAddress.new(addr: "8.17.205.0/24"), IPAddress.new(addr: "8.17.206.0/24"),
    IPAddress.new(addr: "8.18.113.0/24"), IPAddress.new(addr: "8.18.194.0/23"), IPAddress.new(addr: "8.18.196.0/24"),
    IPAddress.new(addr: "8.18.50.0/24"), IPAddress.new(addr: "8.19.10.0/24"), IPAddress.new(addr: "8.19.8.0/24"),
    IPAddress.new(addr: "8.20.100.0/23"), IPAddress.new(addr: "8.20.103.0/24"), IPAddress.new(addr: "8.20.122.0/23"),
    IPAddress.new(addr: "8.20.124.0/22"), IPAddress.new(addr: "8.20.253.0/24"), IPAddress.new(addr: "8.21.110.0/23"),
    IPAddress.new(addr: "8.21.13.0/24"), IPAddress.new(addr: "8.21.238.0/24"), IPAddress.new(addr: "8.21.8.0/22"),
    IPAddress.new(addr: "8.23.139.0/24"), IPAddress.new(addr: "8.23.240.0/24"), IPAddress.new(addr: "8.31.160.0/23"),
    IPAddress.new(addr: "8.35.211.0/24"), IPAddress.new(addr: "8.35.57.0/24"), IPAddress.new(addr: "8.35.58.0/23"),
    IPAddress.new(addr: "8.36.216.0/23"), IPAddress.new(addr: "8.36.218.0/24"), IPAddress.new(addr: "8.36.220.0/24"),
    IPAddress.new(addr: "8.37.41.0/24"), IPAddress.new(addr: "8.37.43.0/24"), IPAddress.new(addr: "8.38.147.0/24"),
    IPAddress.new(addr: "8.38.148.0/23"), IPAddress.new(addr: "8.38.172.0/24"), IPAddress.new(addr: "8.39.125.0/24"),
    IPAddress.new(addr: "8.39.126.0/23"), IPAddress.new(addr: "8.39.18.0/24"), IPAddress.new(addr: "8.39.201.0/24"),
    IPAddress.new(addr: "8.39.202.0/23"), IPAddress.new(addr: "8.39.204.0/22"), IPAddress.new(addr: "8.39.212.0/22"),
    IPAddress.new(addr: "8.39.6.0/24"), IPAddress.new(addr: "8.40.107.0/24"), IPAddress.new(addr: "8.40.111.0/24"),
    IPAddress.new(addr: "8.40.140.0/24"), IPAddress.new(addr: "8.40.26.0/23"), IPAddress.new(addr: "8.40.28.0/22"),
    IPAddress.new(addr: "8.41.36.0/23"), IPAddress.new(addr: "8.41.39.0/24"), IPAddress.new(addr: "8.41.5.0/24"),
    IPAddress.new(addr: "8.41.6.0/23"), IPAddress.new(addr: "8.42.161.0/24"), IPAddress.new(addr: "8.42.164.0/24"),
    IPAddress.new(addr: "8.42.172.0/24"), IPAddress.new(addr: "8.42.245.0/24"), IPAddress.new(addr: "8.42.51.0/24"),
    IPAddress.new(addr: "8.42.52.0/24"), IPAddress.new(addr: "8.42.54.0/23"), IPAddress.new(addr: "8.43.121.0/24"),
    IPAddress.new(addr: "8.43.122.0/23"), IPAddress.new(addr: "8.43.224.0/23"), IPAddress.new(addr: "8.43.226.0/24"),
    IPAddress.new(addr: "8.44.0.0/22"), IPAddress.new(addr: "8.44.58.0/23"), IPAddress.new(addr: "8.44.6.0/24"),
    IPAddress.new(addr: "8.44.60.0/22"), IPAddress.new(addr: "8.45.100.0/23"), IPAddress.new(addr: "8.45.102.0/24"),
    IPAddress.new(addr: "8.45.108.0/24"), IPAddress.new(addr: "8.45.111.0/24"), IPAddress.new(addr: "8.45.144.0/22"),
    IPAddress.new(addr: "8.45.151.0/24"), IPAddress.new(addr: "8.45.41.0/24"), IPAddress.new(addr: "8.45.42.0/23"),
    IPAddress.new(addr: "8.45.44.0/22"), IPAddress.new(addr: "8.45.97.0/24"), IPAddress.new(addr: "8.46.113.0/24"),
    IPAddress.new(addr: "8.46.114.0/23"), IPAddress.new(addr: "8.46.116.0/22"), IPAddress.new(addr: "8.47.12.0/22"),
    IPAddress.new(addr: "8.47.69.0/24"), IPAddress.new(addr: "8.47.71.0/24"), IPAddress.new(addr: "8.47.9.0/24"),
    IPAddress.new(addr: "8.48.130.0/24"), IPAddress.new(addr: "8.48.132.0/23"), IPAddress.new(addr: "8.48.134.0/24"),
    IPAddress.new(addr: "8.6.112.0/24"), IPAddress.new(addr: "8.6.144.0/23"), IPAddress.new(addr: "8.6.146.0/24"),
    IPAddress.new(addr: "8.9.230.0/23"),

    # References: https://ipinfo.io/AS209242
    # AS209242 - Cloudflare London, LLC

    IPAddress.new(addr: "103.156.22.0/23"), IPAddress.new(addr: "103.160.204.0/24"), IPAddress.new(addr: "12.221.133.0/24"),
    IPAddress.new(addr: "141.193.213.0/24"), IPAddress.new(addr: "154.16.228.0/24"), IPAddress.new(addr: "176.126.206.0/23"),
    IPAddress.new(addr: "185.109.21.0/24"), IPAddress.new(addr: "185.162.228.0/23"), IPAddress.new(addr: "185.162.230.0/23"),
    IPAddress.new(addr: "185.170.166.0/24"), IPAddress.new(addr: "185.171.230.0/23"), IPAddress.new(addr: "185.174.138.0/24"),
    IPAddress.new(addr: "185.193.28.0/23"), IPAddress.new(addr: "185.193.30.0/23"), IPAddress.new(addr: "185.201.139.0/24"),
    IPAddress.new(addr: "185.207.92.0/24"), IPAddress.new(addr: "185.221.160.0/24"), IPAddress.new(addr: "185.235.180.0/22"),
    IPAddress.new(addr: "191.101.251.0/24"), IPAddress.new(addr: "193.135.101.0/24"), IPAddress.new(addr: "194.152.44.0/24"),
    IPAddress.new(addr: "194.169.194.0/24"), IPAddress.new(addr: "194.53.53.0/24"), IPAddress.new(addr: "194.53.55.0/24"),
    IPAddress.new(addr: "195.245.221.0/24"), IPAddress.new(addr: "199.60.103.0/24"), IPAddress.new(addr: "203.107.173.0/24"),
    IPAddress.new(addr: "203.13.32.0/24"), IPAddress.new(addr: "203.17.126.0/24"), IPAddress.new(addr: "203.22.223.0/24"),
    IPAddress.new(addr: "203.23.103.0/24"), IPAddress.new(addr: "203.23.104.0/24"), IPAddress.new(addr: "203.23.106.0/24"),
    IPAddress.new(addr: "203.24.102.0/24"), IPAddress.new(addr: "203.24.103.0/24"), IPAddress.new(addr: "203.24.108.0/24"),
    IPAddress.new(addr: "203.24.109.0/24"), IPAddress.new(addr: "203.28.8.0/24"), IPAddress.new(addr: "203.28.9.0/24"),
    IPAddress.new(addr: "203.29.52.0/24"), IPAddress.new(addr: "203.29.53.0/24"), IPAddress.new(addr: "203.29.54.0/23"),
    IPAddress.new(addr: "203.30.188.0/22"), IPAddress.new(addr: "203.32.120.0/23"), IPAddress.new(addr: "203.34.28.0/24"),
    IPAddress.new(addr: "203.34.80.0/24"), IPAddress.new(addr: "203.55.107.0/24"), IPAddress.new(addr: "207.189.149.0/24"),
    IPAddress.new(addr: "212.110.134.0/23"), IPAddress.new(addr: "45.12.30.0/23"), IPAddress.new(addr: "45.131.208.0/22"),
    IPAddress.new(addr: "45.131.4.0/22"), IPAddress.new(addr: "45.133.246.0/24"), IPAddress.new(addr: "45.133.247.0/24"),
    IPAddress.new(addr: "45.14.173.0/24"), IPAddress.new(addr: "45.14.174.0/24"), IPAddress.new(addr: "45.8.104.0/22"),
    IPAddress.new(addr: "45.85.118.0/23"), IPAddress.new(addr: "5.181.28.0/24"), IPAddress.new(addr: "5.252.118.0/24"),
    IPAddress.new(addr: "64.72.226.0/24"), IPAddress.new(addr: "89.47.56.0/23"), IPAddress.new(addr: "91.132.150.0/23"),
    IPAddress.new(addr: "91.192.106.0/23"), IPAddress.new(addr: "91.226.97.0/24"), IPAddress.new(addr: "93.114.64.0/23"),

    # References: https://ipinfo.io/AS132892
    # AS132892 - Cloudflare, Inc.

    IPAddress.new(addr: "103.21.246.0/24"), IPAddress.new(addr: "103.21.247.0/24"), IPAddress.new(addr: "162.158.64.0/21"),
    IPAddress.new(addr: "172.69.24.0/21"), IPAddress.new(addr: "172.70.0.0/19"), IPAddress.new(addr: "198.41.144.0/22"),
    IPAddress.new(addr: "198.41.244.0/24"), IPAddress.new(addr: "198.41.245.0/24"), IPAddress.new(addr: "198.41.246.0/23"),
    IPAddress.new(addr: "198.41.248.0/23"), IPAddress.new(addr: "198.41.250.0/24"), IPAddress.new(addr: "198.41.251.0/24"),
    IPAddress.new(addr: "198.41.254.0/24"), IPAddress.new(addr: "198.41.255.0/24"),

    # References: https://ipinfo.io/AS139242
    # AS139242 - Cloudflare Sydney, LLC

    IPAddress.new(addr: "185.212.144.0/24"),

    # References: https://ipinfo.io/AS202623
    # AS202623 - Cloudflare Inc

    IPAddress.new(addr: "198.41.148.0/22"), IPAddress.new(addr: "198.41.148.0/24"), IPAddress.new(addr: "198.41.152.0/22"),
    IPAddress.new(addr: "198.41.245.0/24"), IPAddress.new(addr: "198.41.252.0/24"), IPAddress.new(addr: "198.41.253.0/24"),
    IPAddress.new(addr: "198.41.254.0/24"), IPAddress.new(addr: "198.41.255.0/24"),

    # References: https://ipinfo.io/AS395747
    # AS395747 - Cloudflare, Inc.

    IPAddress.new(addr: "103.31.4.0/22"), IPAddress.new(addr: "172.69.209.0/24"), IPAddress.new(addr: "173.245.60.0/23"),
    IPAddress.new(addr: "198.41.130.0/24"), IPAddress.new(addr: "198.41.132.0/22"), IPAddress.new(addr: "198.41.136.0/22"),
    IPAddress.new(addr: "8.17.207.0/24"), IPAddress.new(addr: "8.48.131.0/24"),

    # References: https://ipinfo.io/AS203898
    # AS203898 - Cloudflare Inc

    IPAddress.new(addr: "185.122.0.0/24"),
  }

  Ipv6 = Set{
    # References: https://ipinfo.io/AS13335
    # AS13335 - Cloudflare, Inc.

    IPAddress.new(addr: "2400:cb00:22::/48"), IPAddress.new(addr: "2400:cb00:26::/48"), IPAddress.new(addr: "2400:cb00:34::/48"),
    IPAddress.new(addr: "2400:cb00:41::/48"), IPAddress.new(addr: "2400:cb00:46::/48"), IPAddress.new(addr: "2400:cb00:47::/48"),
    IPAddress.new(addr: "2400:cb00:51::/48"), IPAddress.new(addr: "2400:cb00:55::/48"), IPAddress.new(addr: "2400:cb00:57::/48"),
    IPAddress.new(addr: "2400:cb00:58::/48"), IPAddress.new(addr: "2400:cb00:59::/48"), IPAddress.new(addr: "2400:cb00:68::/48"),
    IPAddress.new(addr: "2400:cb00:80::/48"), IPAddress.new(addr: "2400:cb00:84::/48"), IPAddress.new(addr: "2400:cb00:85::/48"),
    IPAddress.new(addr: "2400:cb00:86::/48"), IPAddress.new(addr: "2400:cb00:92::/48"), IPAddress.new(addr: "2400:cb00:93::/48"),
    IPAddress.new(addr: "2400:cb00:96::/48"), IPAddress.new(addr: "2400:cb00:105::/48"), IPAddress.new(addr: "2400:cb00:110::/48"),
    IPAddress.new(addr: "2400:cb00:111::/48"), IPAddress.new(addr: "2400:cb00:112::/48"), IPAddress.new(addr: "2400:cb00:117::/48"),
    IPAddress.new(addr: "2400:cb00:122::/48"), IPAddress.new(addr: "2400:cb00:127::/48"), IPAddress.new(addr: "2400:cb00:129::/48"),
    IPAddress.new(addr: "2400:cb00:134::/48"), IPAddress.new(addr: "2400:cb00:141::/48"), IPAddress.new(addr: "2400:cb00:142::/48"),
    IPAddress.new(addr: "2400:cb00:145::/48"), IPAddress.new(addr: "2400:cb00:161::/48"), IPAddress.new(addr: "2400:cb00:165::/48"),
    IPAddress.new(addr: "2400:cb00:175::/48"), IPAddress.new(addr: "2400:cb00:207::/48"), IPAddress.new(addr: "2400:cb00:208::/48"),
    IPAddress.new(addr: "2400:cb00:212::/48"), IPAddress.new(addr: "2400:cb00:223::/48"), IPAddress.new(addr: "2400:cb00:225::/48"),
    IPAddress.new(addr: "2400:cb00:227::/48"), IPAddress.new(addr: "2400:cb00:229::/48"), IPAddress.new(addr: "2400:cb00:231::/48"),
    IPAddress.new(addr: "2400:cb00:232::/48"), IPAddress.new(addr: "2400:cb00:233::/48"), IPAddress.new(addr: "2400:cb00:234::/48"),
    IPAddress.new(addr: "2400:cb00:236::/48"), IPAddress.new(addr: "2400:cb00:238::/48"), IPAddress.new(addr: "2400:cb00:239::/48"),
    IPAddress.new(addr: "2400:cb00:240::/48"), IPAddress.new(addr: "2400:cb00:245::/48"), IPAddress.new(addr: "2400:cb00:a160::/48"),
    IPAddress.new(addr: "2400:cb00:a163::/48"), IPAddress.new(addr: "2400:cb00:a170::/48"), IPAddress.new(addr: "2400:cb00:a174::/48"),
    IPAddress.new(addr: "2400:cb00:a1a0::/48"), IPAddress.new(addr: "2400:cb00:a1a2::/48"), IPAddress.new(addr: "2400:cb00:a220::/48"),
    IPAddress.new(addr: "2400:cb00:a222::/48"), IPAddress.new(addr: "2400:cb00:a230::/48"), IPAddress.new(addr: "2400:cb00:a234::/48"),
    IPAddress.new(addr: "2400:cb00:a2e0::/48"), IPAddress.new(addr: "2400:cb00:a2e1::/48"), IPAddress.new(addr: "2400:cb00:a2f0::/48"),
    IPAddress.new(addr: "2400:cb00:a2f2::/48"), IPAddress.new(addr: "2400:cb00:a330::/48"), IPAddress.new(addr: "2400:cb00:a332::/48"),
    IPAddress.new(addr: "2400:cb00:a3a0::/48"), IPAddress.new(addr: "2400:cb00:a3a1::/48"), IPAddress.new(addr: "2400:cb00:a500::/48"),
    IPAddress.new(addr: "2400:cb00:a502::/48"), IPAddress.new(addr: "2400:cb00:a540::/48"), IPAddress.new(addr: "2400:cb00:a542::/48"),
    IPAddress.new(addr: "2400:cb00:a550::/48"), IPAddress.new(addr: "2400:cb00:a552::/48"), IPAddress.new(addr: "2a09:bac0:22::/48"),
    IPAddress.new(addr: "2a09:bac0:26::/48"), IPAddress.new(addr: "2a09:bac0:46::/48"), IPAddress.new(addr: "2a09:bac0:47::/48"),
    IPAddress.new(addr: "2a09:bac0:51::/48"), IPAddress.new(addr: "2a09:bac0:80::/48"), IPAddress.new(addr: "2a09:bac0:84::/48"),
    IPAddress.new(addr: "2a09:bac0:85::/48"), IPAddress.new(addr: "2a09:bac0:134::/48"), IPAddress.new(addr: "2a09:bac0:145::/48"),
    IPAddress.new(addr: "2a09:bac0:165::/48"), IPAddress.new(addr: "2a09:bac0:227::/48"), IPAddress.new(addr: "2a09:bac0:232::/48"),

    # References: https://ipinfo.io/AS209242
    # AS209242 - Cloudflare London, LLC

    IPAddress.new(addr: "2a00:1c88:100::/48"), IPAddress.new(addr: "2a05:7880::/32"), IPAddress.new(addr: "2a06:9ac0::/32"),
    IPAddress.new(addr: "2a07:180::/32"),

    # References: https://ipinfo.io/AS132892
    # AS132892 - Cloudflare, Inc.

    IPAddress.new(addr: "2400:cb00:36::/48"), IPAddress.new(addr: "2606:4700:1100::/40"), IPAddress.new(addr: "2a06:98c0:3600::/48"),
    IPAddress.new(addr: "2a06:98c0:3601::/48"), IPAddress.new(addr: "2a06:98c0:3602::/48"), IPAddress.new(addr: "2a06:98c0:3603::/48"),
    IPAddress.new(addr: "2a06:98c0:3604::/48"), IPAddress.new(addr: "2a06:98c0:3605::/48"), IPAddress.new(addr: "2a06:98c0:3606::/48"),
    IPAddress.new(addr: "2a06:98c0:3607::/48"),

    # References: https://ipinfo.io/AS139242
    # AS139242 - Cloudflare Sydney, LLC

    IPAddress.new(addr: "2a06:98c0:1001::/48"),

    # References: https://ipinfo.io/AS394536
    # AS394536 - Cloudflare, Inc.

    IPAddress.new(addr: "2606:4700:ff01::/48"),

    # References: https://ipinfo.io/AS202623
    # AS202623 - Cloudflare Inc

    IPAddress.new(addr: "2a06:98c0:1400::/48"), IPAddress.new(addr: "2a06:98c0:1401::/48"), IPAddress.new(addr: "2a06:98c0:3603::/48"),
    IPAddress.new(addr: "2a06:98c0:3605::/48"), IPAddress.new(addr: "2a06:98c0:3606::/48"), IPAddress.new(addr: "2a06:98c0:3607::/48"),

    # References: https://ipinfo.io/AS395747
    # AS395747 - Cloudflare, Inc.

    IPAddress.new(addr: "2400:cb00:131::/48"), IPAddress.new(addr: "2400:cb00:133::/48"), IPAddress.new(addr: "2400:cb00:171::/48"),
    IPAddress.new(addr: "2400:cb00:302::/48"), IPAddress.new(addr: "2606:4700:2001::/48"), IPAddress.new(addr: "2606:4700:3131::/48"),
    IPAddress.new(addr: "2606:4700:ff01::/48"), IPAddress.new(addr: "2606:4700:ff02::/48"), IPAddress.new(addr: "2a09:bac0:108::/48"),
    IPAddress.new(addr: "2a09:bac0:131::/48"),

    # References: https://ipinfo.io/AS203898
    # AS203898 - Cloudflare Inc

    IPAddress.new(addr: "2a06:98c0:1000::/48"),
  }

  def self.includes?(ip_address : Socket::IPAddress) : Bool
    _ip_address = IPAddress.new addr: ip_address.address

    Ipv4.each { |subnet| return true if subnet.includes? _ip_address }
    return false if ip_address.family.inet?

    Ipv6.each { |subnet| return true if subnet.includes? _ip_address }
    return false if ip_address.family.inet6?

    false
  end
end
