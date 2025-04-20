# frozen_string_literal: true

require "json"

module HelcimRuby
  class Response
    attr_reader :raw_response, :status, :body

    def initialize(raw_response)
      @raw_response = raw_response
      @status = raw_response.code
      @body = parse_body(raw_response.body)
    end

    def success?
      [200, 201, 204].include?(status)
    end

    def parsed_body
      @body
    end

    def error_message
      return nil if success?

      @body["message"] || raw_response.message
    end

    def raise_error
      case status
      when 401
        raise HelcimRuby::UnauthorizedError, "Unauthorized: Invalid API token"
      when 404
        raise HelcimRuby::NotFoundError, "Resource not found"
      when 422
        raise HelcimRuby::RequestFailedError, "Invalid request: #{@body["errors"] || raw_response.message}"
      else
        raise HelcimRuby::RequestFailedError, "API request failed: #{raw_response.message}"
      end
    end

    private

    def parse_body(body)
      return {} if body.nil? || body.empty? # Handle 204 No Content

      JSON.parse(body)
    rescue JSON::ParserError
      body # Return raw string if not JSON
    end
  end
end
