module HelcimRuby
  module Resources
    class Connection
      def initialize(client)
        @client = client
      end

      def test
        raw_response = @client.class.get("/connection-test", headers: @client.default_headers)
        response = HelcimRuby::Response.new(raw_response)
        response.raise_error unless response.success?
        response.parsed_body
      end
    end
  end
end