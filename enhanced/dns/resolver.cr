class DNS::Resolver
  def cloudflare=(value : Cloudflare::Scanner?)
    @cloudflare = value
  end

  def cloudflare
    @cloudflare
  end

  def getaddrinfo(host : String, port : Int32 = 0_i32, answer_safety_first : Bool = options.addrinfo.answerSafetyFirst,
                  addrinfo_override : Bool = cloudflare.try &.options.switcher.addrinfoOverride) : Tuple(FetchType, Array(Socket::IPAddress))
    # This function is used as an overridable.
    # E.g. Cloudflare.

    fetch_type, ip_addresses = addrinfo_tuple = getaddrinfo! host: host, port: port, answer_safety_first: answer_safety_first
    _cloudflare = cloudflare

    if _cloudflare && addrinfo_override
      allowed_fetch_type = fetch_type.server? || fetch_type.caching? || fetch_type.local?
      consistent_port = ip_addresses.all? { |ip_address| port == ip_address.port }

      if consistent_port && allowed_fetch_type
        block_includes = Cloudflare::Block.includes? ip_addresses.first unless ip_addresses.empty?

        if block_includes
          cloudflare_ip_addresses = _cloudflare.caching_to_tuple_ip_addresses.map do |address_tuple|
            Socket::IPAddress.new address: address_tuple.last.address, port: port
          end

          return Tuple.new FetchType::Override, cloudflare_ip_addresses unless cloudflare_ip_addresses.empty?
        end
      end
    end

    addrinfo_tuple
  end
end
