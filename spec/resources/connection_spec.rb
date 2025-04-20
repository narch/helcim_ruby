# spec/helcim_ruby/resources/connection_spec.rb
require "spec_helper"

RSpec.describe HelcimRuby::Resources::Connection do
  let(:client) { HelcimRuby::Client.new(ENV["HELCIM_API_TOKEN"]) }
  let(:connection) { described_class.new(client) }

  describe "#test", :vcr do
    it "returns a successful connection response" do
      result = connection.test
      expect(result["message"]).to eq("Connected Successfully")
    end
  end
end