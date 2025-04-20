require "httparty"

module HelcimRuby
  class Client
    include HTTParty
    base_uri HelcimRuby.configuration&.base_uri || "https://api.helcim.com/v2"

    attr_reader :api_token

    def initialize(api_token = nil)
      @api_token = api_token || HelcimRuby.configuration&.api_token
      raise HelcimRuby::Error, "API token is required" unless @api_token
    end

    def connection
      HelcimRuby::Resources::Connection.new(self)
    end

    def payment
      HelcimRuby::Resources::Payment.new(self)
    end

    def customers
      HelcimRuby::Resources::Customers.new(self)
    end

    def cards(customer_id)
      HelcimRuby::Resources::Cards.new(self, customer_id)
    end

    def payment_plans
    end

    def default_headers
      {
        "api-token" => api_token,
        "accept" => "application/json",
        "content-type" => "application/json"
      }
    end
  end
end