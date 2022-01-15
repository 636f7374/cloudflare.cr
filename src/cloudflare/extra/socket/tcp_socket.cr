class TCPSocket < IPSocket
  def initialize(ip_address : IPAddress, dns_timeout = nil, connect_timeout = nil, blocking = false)
    Addrinfo.build_tcp ip_address: ip_address do |addrinfo|
      super addrinfo.family, addrinfo.type, addrinfo.protocol, blocking
      connect(addrinfo, timeout: connect_timeout) do |error|
        close
        error
      end
    end
  end
end
