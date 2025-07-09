require 'faraday'
require 'faraday/follow_redirects'
require 'faraday/multipart'
require 'faraday/http'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/hash'

class Happi::Client
  def config
    @config ||= self.class.config.dup
  end

  def self.config
    @global_config ||= Happi::Configuration.new
  end

  def self.configure
    yield config
  end

  def initialize(options = {})
    options.each do |key, value|
      config.send("#{key}=", value)
    end
  end

  def get(resource, params = {})
    call(:get, url(resource), param_check(params))
        .body.with_indifferent_access
  end

  def delete(resource, params = {})
    call(:delete, url(resource), param_check(params))
        .body.with_indifferent_access
  end

  def patch(resource, params = {})
    call(:patch, url(resource), param_check(params))
        .body.with_indifferent_access
  end

  def post(resource, params = {})
    call(:post, url(resource), param_check(params))
        .body.with_indifferent_access
  end

  def url(resource)
    "/api/#{config.version}/#{resource}"
  end

  def call(method, url, params)
    if config.log_level == :debug
      logger.debug("Happi: #{method.upcase} #{config.host}#{url}, #{params}")
    else
      logger.info("Happi: #{method.upcase} #{config.host}#{url}")
    end

    response = connection.send(method, url, params)
    raise_error(response) if errors[response.status]
    response
  end

  def raise_error(response)
    if response.body['errors']
      message = response.body['errors']
    else
      message = response.body
    end

    fail errors[response.status].new(message, response)
  end

  def logger
    @logger ||= default_logger
  end

  def default_logger
    if defined?(Rails)
      Rails.try(:logger) || Logger.new(STDOUT)
    else
      Logger.new(STDOUT)
    end
  end

  def param_check(params)
    Hash[params.map do |key, value|
      if value.is_a? Hash
        [key, param_check(value)]
      elsif value.respond_to?(:multipart)
        [key, value.multipart]
      else
        [key, value]
      end
    end]
  end

  def retry_options
    {
      max: 3,
      interval: 0.05,
      interval_randomness: 0.5,
      backoff_factor: 2
    }
  end

  def connection
    @connection ||= Faraday.new(config.host) do |f|
      f.request :authorization, 'Bearer', -> { config.oauth_token }
      f.request :retry, retry_options
      f.use Faraday::FollowRedirects::Middleware  # default limit is 3

      if self.config.use_json
        f.request :json
        f.response :json
      else
        f.request :multipart
        f.request :url_encoded
      end

      f.adapter :http
    end
  end

  def connection_options
    if config.token_type.present?
      { token_type: config.token_type }
    else
      { }
    end
  end

  def errors
    @errors ||= {
      400 => Happi::Error::BadRequest,
      401 => Happi::Error::Unauthorized,
      403 => Happi::Error::Forbidden,
      404 => Happi::Error::NotFound,
      406 => Happi::Error::NotAcceptable,
      408 => Happi::Error::RequestTimeout,
      422 => Happi::Error::UnprocessableEntity,
      429 => Happi::Error::TooManyRequests,
      500 => Happi::Error::InternalServerError,
      502 => Happi::Error::BadGateway,
      503 => Happi::Error::ServiceUnavailable,
      504 => Happi::Error::GatewayTimeout,
    }
  end
end
