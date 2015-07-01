class Happi::Error < StandardError
  attr_reader :response

  def initialize(msg = nil, response = nil)
    super(msg)
    @response = response
  end

  class ClientError < self
    def message
      "A client error occurred"
    end
  end

  class BadRequest < ClientError
    def message
      "The request was incorrectly performed"
    end
  end

  class Unauthorized < ClientError
    def message
      "The request was not authorized"
    end
  end

  class Forbidden < ClientError
    def message
      "The request was denied"
    end
  end

  class NotFound < ClientError
    def message
      "The requested resource was not found"
    end
  end

  class NotAcceptable < ClientError
    def message
      "The requested format was not accepted"
    end
  end

  class RequestTimeout < ClientError
    def message
      "The request timed out"
    end
  end

  class UnprocessableEntity < ClientError
    def message
      "The request was not able to be processed"
    end
  end

  class ServerError < self
    def message
      "A server error occurred"
    end
  end

  class InternalServerError < ServerError; end
  class BadGateway < ServerError; end
  class TooManyRequests < ServerError; end
  class ServiceUnavailable < ServerError; end
  class GatewayTimeout < ServerError; end

  module ServiceableErrors
    def self.included(serviceable)
      serviceable.const_set :StandardError, Class.new(::NestedError)
      serviceable.const_set :UserError, Class.new(serviceable::StandardError)
      serviceable.const_set :LogicError, Class.new(serviceable::StandardError)
      serviceable.const_set :InternalError, Class.new(serviceable::LogicError)
      serviceable.const_set :ClientError, Class.new(serviceable::LogicError)
      serviceable.const_set :TransientFailure, Class.new(serviceable::StandardError)
    end

    class NestedError < StandardError
      attr_reader :original

      def initialize(msg, original = $1)
        super(original ? "#{msg} - #{original.message}" : msg)
        @original = original
        set_backtrace(@original.backtrace) if @original.present?
      end

      def original?
        @original.nil?
      end
    end
  end
end
