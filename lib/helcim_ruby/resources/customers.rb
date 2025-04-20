# frozen_string_literal: true

module HelcimRuby
  module Resources
    class Customers
      def initialize(client)
        @client = client
      end

      def create(**params)
        transformed_params = HelcimRuby::Utils.transform_to_camel_case(params)

        raw_response = @client.class.post(
          "/customers",
          headers: @client.default_headers,
          body: transformed_params.to_json
        )

        response = HelcimRuby::Response.new(raw_response)
        response.raise_error unless response.success?
        Customer.new(response.parsed_body)
      end

      def get(customer_id)
        raw_response = @client.class.get("/customers/#{customer_id}", headers: @client.default_headers)
        response = HelcimRuby::Response.new(raw_response)
        response.raise_error unless response.success?
        Customer.new(response.parsed_body)
      end

      def update(customer_id, **options)
        raw_response = @client.class.put(
          "/customers/#{customer_id}",
          headers: @client.default_headers,
          body: { id: customer_id, **options }.to_json
        )
        response = HelcimRuby::Response.new(raw_response)
        response.raise_error unless response.success?
        Customer.new(response.parsed_body)
      end

      def list(**options)
        query_params = HelcimRuby::Utils.transform_to_camel_case({
          search: options[:search],
          customer_code: options[:customer_code],
          limit: options[:limit],
          page: options[:page],
          include_cards: options[:include_cards]
        }.compact)

        raw_response = @client.class.get(
          "/customers",
          headers: @client.default_headers,
          query: query_params
        )
        response = HelcimRuby::Response.new(raw_response)
        response.raise_error unless response.success?
        Collection.from_response(response.parsed_body, type: Customer)
      end

      def cards(customer_id)
        Cards.new(@client, customer_id)
      end
    end
  end
end
