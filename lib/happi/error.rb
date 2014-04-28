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
end
