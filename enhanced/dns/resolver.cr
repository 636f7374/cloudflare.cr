class DNS::Resolver
  def cloudflare=(value : Cloudflare::Scanner?)
    @cloudflare = value
  end

  def cloudflare
    @cloudflare
  end

  def getaddrinfo(host : String, port : Int32 = 0_i32, answer_safety_first : Bool = options.addrinfo.answerSafetyFirst) : Tuple(FetchType, Array(Socket::IPAddress))
    # This function is used as an overloadable.
    # E.g. Cloudflare.

    fetch_type, ip_addresses = tuple = getaddrinfo! host: host, port: port, answer_safety_first: answer_safety_first
    _cloudflare = cloudflare

    allowed_fetch_type = fetch_type.server? || fetch_type.caching? || fetch_type.local?
    consistent_port = ip_addresses.all? { |ip_address| port == ip_address.port }

    if _cloudflare && consistent_port && allowed_fetch_type
      unless ip_addresses.empty?
        subnet_includes = Cloudflare::Subnet.includes? ip_addresses.first
      end

      if subnet_includes
        cloudflare_ip_addresses = _cloudflare.caching_to_tuple_ip_addresses.map do |tuple|
          Socket::IPAddress.new address: tuple.last.address, port: port
        end

        return Tuple.new fetch_type, cloudflare_ip_addresses unless cloudflare_ip_addresses.empty?
      end
    end

    tuple
  end
end
