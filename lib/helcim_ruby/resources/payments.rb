require "securerandom"

module HelcimRuby
  module Resources
    class Payments
      def initialize(client)
        @client = client
      end

      def purchase(card_token:, amount:, ip_address:, **options)
        raise ArgumentError, "Required arguments cannot be nil" if [card_token, amount, ip_address].any?(&:nil?)

        post_payment("/payment/purchase", build_payment_body(card_token, amount, ip_address, options))
      end

      def preauth(card_token:, amount:, ip_address:, **options)
        raise ArgumentError, "Required arguments cannot be nil" if [card_token, amount, ip_address].any?(&:nil?)

        post_payment("/payment/preauth", build_payment_body(card_token, amount, ip_address, options))
      end

      def capture(transaction_id:, amount:, ip_address: nil, **options)
        raise ArgumentError, "Required arguments cannot be nil" if [transaction_id, amount].any?(&:nil?)

        post_payment("/payment/capture", {
          pre_auth_transaction_id: transaction_id.to_s,
          amount: amount.to_f,
          currency: options[:currency] || HelcimRuby.configuration.default_currency,
          ip_address: ip_address || "127.0.0.1"
        })
      end

      def refund(transaction_id:, amount:, ip_address: nil, **options)
        raise ArgumentError, "Required arguments cannot be nil" if [transaction_id, amount].any?(&:nil?)

        post_payment("/payment/refund", {
          original_transaction_id: transaction_id.to_s,
          amount: amount.to_f,
          currency: options[:currency] || HelcimRuby.configuration.default_currency,
          ip_address: ip_address || "127.0.0.1"
        })
      end

      def reverse(transaction_id:, ip_address: nil, **options)
        raise ArgumentError, "transaction_id cannot be nil" if transaction_id.nil?

        post_payment("/payment/reverse", {
          card_transaction_id: transaction_id.to_s,
          ip_address: ip_address || "127.0.0.1"
        }.compact)
      end

      private

      def post_payment(endpoint, body)
        raw_response = @client.class.post(
          endpoint,
          headers: @client.default_headers.merge("idempotency-key" => SecureRandom.uuid[0...25]),
          body: HelcimRuby::Utils.transform_to_camel_case(body).to_json
        )
        response = HelcimRuby::Response.new(raw_response)
        response.raise_error unless response.success?
        PaymentTransaction.new(response.parsed_body)
      end

      def build_payment_body(card_token, amount, ip_address, options)
        {
          amount: amount.to_f,
          currency: options[:currency] || HelcimRuby.configuration.default_currency,
          ip_address: ip_address,
          ecommerce: options[:ecommerce].nil? ? true : options[:ecommerce],
          card_data: {
            card_token: card_token
          },
          customer_code: options[:customer_code]
        }.compact
      end
    end
  end
end