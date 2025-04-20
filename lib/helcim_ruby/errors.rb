module HelcimRuby
  class Error < StandardError; end
  class UnauthorizedError < Error; end
  class NotFoundError < Error; end
  class RequestFailedError < Error; end
end