require 'faraday'
require 'faraday_middleware'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/hash'

class Happi::Client
  delegate :config, to: self

  def self.config
    @config ||= Happi::Configuration.new
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
    logger.info("#{method}, #{url}, #{params}")
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

    fail errors[response.status].new(message)
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

  def connection
    @connection ||= Faraday.new(config.host) do |f|
      f.use FaradayMiddleware::OAuth2, config.oauth_token
      f.use FaradayMiddleware::ParseJson, content_type: 'application/json'
      f.adapter :net_http

      if self.config.use_json
        f.use FaradayMiddleware::EncodeJson
        f.request :json
        f.response :json
      else
        f.request :multipart
        f.request :url_encoded
      end
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
