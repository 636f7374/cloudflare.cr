class DNS::Resolver
  def cloudflare=(value : Cloudflare::Scanner?)
    @cloudflare = value
  end

  def cloudflare
    @cloudflare
  end

  def __getaddrinfo_cloudflare(host : String, port : Int32 = 0_i32, answer_safety_first : Bool = options.addrinfo.answerSafetyFirst,
                               addrinfo_overridable : Bool? = cloudflare.try &.options.scanner.quirks.addrinfoOverride) : Tuple(Symbol, FetchType, Array(Socket::IPAddress))
    # port.zero? (E.g. Warpless).
    # This function is used as an overridable.
    # E.g. Cloudflare.

    delegator, fetch_type, ip_addresses = addrinfo_tuple = __getaddrinfo host: host, port: port, answer_safety_first: answer_safety_first
    _cloudflare = cloudflare

    if _cloudflare && addrinfo_overridable
      allowed_fetch_type = fetch_type.remote? || fetch_type.caching? || fetch_type.local?
      consistent_port = ip_addresses.all? { |ip_address| port == ip_address.port }

      if (consistent_port || port.zero?) && allowed_fetch_type
        ip_block_includes = Cloudflare::IpBlock.includes? ip_addresses.first unless ip_addresses.empty?

        if ip_block_includes
          cloudflare_ip_addresses = _cloudflare.caching_to_tuple_ip_addresses.map do |address_tuple|
            Socket::IPAddress.new address: address_tuple.last.address, port: port
          end

          return Tuple.new :__getaddrinfo_cloudflare, FetchType::Override, cloudflare_ip_addresses unless cloudflare_ip_addresses.empty?
        end
      end
    end

    addrinfo_tuple
  end

  def getaddrinfo(host : String, port : Int32 = 0_i32, caller : Symbol? = nil, answer_safety_first : Bool? = nil, addrinfo_overridable : Bool? = nil) : Tuple(Symbol, FetchType, Array(Socket::IPAddress))
    service_mapper_entry = serviceMapperCaching.get? host: host, port: port
    answer_safety_first = service_mapper_entry.options.answerSafetyFirst if service_mapper_entry && answer_safety_first.nil?
    addrinfo_overridable = service_mapper_entry.options.overridable if service_mapper_entry && addrinfo_overridable.nil?

    answer_safety_first = options.addrinfo.answerSafetyFirst if answer_safety_first.nil?
    addrinfo_overridable = cloudflare.try &.options.scanner.quirks.addrinfoOverride if addrinfo_overridable.nil?

    __getaddrinfo_cloudflare host: host, port: port, answer_safety_first: answer_safety_first, addrinfo_overridable: addrinfo_overridable
  end
end
