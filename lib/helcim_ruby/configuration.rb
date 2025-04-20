# frozen_string_literal: true

# lib/helcim_ruby/configuration.rb
module HelcimRuby
  class << self
    attr_accessor :configuration
  end

  self.configuration = Configuration.new # Set a default instance

  def self.configure
    yield(configuration) if block_given?
  end

  class Configuration
    attr_accessor :api_token, :base_uri

    def initialize
      @api_token = nil
      @base_uri = "https://api.helcim.com/v2"
    end
  end
end
