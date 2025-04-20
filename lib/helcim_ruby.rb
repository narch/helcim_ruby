# frozen_string_literal: true

module HelcimRuby
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end
  end

  def self.configure
    yield(configuration) if block_given?
  end

  def self.reset
    @configuration = Configuration.new
  end

  class Configuration
    attr_accessor :api_token, :base_uri, :default_currency

    def initialize
      @api_token = nil
      @base_uri = "https://api.helcim.com/v2"
      @default_currency = "USD"
    end
  end
end

require "helcim_ruby/version"
require "helcim_ruby/errors"
require "helcim_ruby/response"
require "helcim_ruby/client"
require "helcim_ruby/resources/connection"
require "helcim_ruby/resources/payments"
require "helcim_ruby/resources/customers"
require "helcim_ruby/resources/cards"
require "helcim_ruby/utils"
require "helcim_ruby/object"
require "helcim_ruby/collection"
require "helcim_ruby/objects/customer"
require "helcim_ruby/objects/card"
require "helcim_ruby/objects/payment_transaction"
require "helcim_ruby/objects/payment_plan"
