struct Cloudflare::Options
  def dns=(value : DNS::Options)
    @dns = value
  end

  def dns
    @dns
  end
end
