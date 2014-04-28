class Happi::Configuration
   DEFAULTS = {
    host: 'http://localhost:8080',
    port: 443,
    timeout: 60,
    version: 'v1'
  }

  attr_accessor :oauth_token, :host, :port, :timeout, :version

  def initialize(options = {})
    DEFAULTS.merge(options).each do |key, value|
      send("#{key}=", value)
    end
  end
end
