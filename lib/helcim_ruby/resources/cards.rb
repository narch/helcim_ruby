# frozen_string_literal: true

module HelcimRuby
  module Resources
    class Cards
      def initialize(client, customer_id)
        @client = client
        @customer_id = customer_id
      end

      def list
        raw_response = @client.class.get(
          "/customers/#{@customer_id}/cards",
          headers: @client.default_headers
        )
        response = HelcimRuby::Response.new(raw_response)
        response.raise_error unless response.success?
        Collection.from_response(response.parsed_body || [], type: Card)
      end

      def set_default(card_id)
        raw_response = @client.class.patch(
          "/customers/#{@customer_id}/cards/#{card_id}/default",
          headers: @client.default_headers
        )
        response = HelcimRuby::Response.new(raw_response)
        response.raise_error unless response.success?
        Card.new(response.parsed_body)
      end

      def destroy(card_id)
        raw_response = @client.class.delete(
          "/customers/#{@customer_id}/cards/#{card_id}",
          headers: @client.default_headers
        )
        response = HelcimRuby::Response.new(raw_response)
        response.raise_error unless response.success?
        true
      end
    end
  end
end
