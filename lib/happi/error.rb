class Happi::Error < Exception
  class ClientError < self; end
  class BadRequest < ClientError; end
  class Unauthorized < ClientError; end
  class Forbidden < ClientError; end
  class NotFound < ClientError; end
  class NotAcceptable < ClientError; end
  class RequestTimeout < ClientError; end
  class UnprocessableEntity < ClientError; end
  class ServerError < self; end
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
