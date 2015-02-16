class Happi::Configuration
  def self.defaults
     {
    host: 'http://localhost:8080',
    port: 443,
    timeout: 60,
    version: 'v1',
    use_json: false,
    log_level: :info
    }
  end

  attr_accessor :oauth_token, :host, :port, :timeout, :version, :use_json, :log_level

  def initialize(options = {})
    self.class.defaults.merge(options).each do |key, value|
      send("#{key}=", value)
    end
  end
end
