struct Cloudflare::TransportLayerSecurity
  property hostname : String
  property options : Set(LibSSL::Options)
  property verifyMode : LibSSL::VerifyMode?

  def initialize(@hostname : String, @options : Set(LibSSL::Options), @verifyMode : LibSSL::VerifyMode?)
  end

  def unwrap : OpenSSL::SSL::Context::Client
    context = OpenSSL::SSL::Context::Client.new

    options.each { |option| context.add_options options: option } rescue nil
    verifyMode.try { |verify_mode| context.verify_mode = verify_mode }

    context
  end
end
