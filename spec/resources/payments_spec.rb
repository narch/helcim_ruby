require "spec_helper"

RSpec.describe HelcimRuby::Resources::Payments do
  let(:client) { HelcimRuby::Client.new(ENV["HELCIM_API_TOKEN"]) }
  let(:connection) { described_class.new(client) }
  let(:test_amount) { rand(100..10000) / 100.0 }

  # Please refer to the README.md file for more information about the testing environment
  let(:customer_code) { "CST1146" }
  let(:card_token) { "cdeed21583e976f9ef4843" }
  let(:reverse_transaction_id) { "33823366" }

  describe "#purchase", :vcr do
    context "with card token" do
      it "processes a purchase with valid card token" do
        response = connection.purchase(
          amount: rand(100..10000) / 100.0,
          currency: "USD",
          card_token: card_token,
          customer_code: customer_code,
          ip_address: "127.0.0.1"
        )

        expect(response).to be_a(HelcimRuby::PaymentTransaction)
        expect(response.status).to eq("APPROVED")
        expect(response.transaction_id).to_not be_nil
        expect(response.amount).to be_a(Numeric)
      end

      it "processes a purchase with different amount" do
        response = connection.purchase(
          amount: rand(100..10000) / 100.0,
          currency: "USD",
          card_token: card_token,
          customer_code: customer_code,
          ip_address: "127.0.0.1"
        )

        expect(response).to be_a(HelcimRuby::PaymentTransaction)
        expect(response.status).to eq("APPROVED")
        expect(response.amount).to be_a(Numeric)
      end
    end

    context "with invalid data" do
      it "raises an error with missing amount" do
        expect {
          connection.purchase(
            amount: nil,
            card_token: card_token,
            customer_code: customer_code,
            ip_address: "127.0.0.1"
          )
        }.to raise_error(ArgumentError)
      end

      it "raises an error with missing card token" do
        expect {
          connection.purchase(
            amount: rand(100..10000) / 100.0,
            card_token: nil,
            customer_code: customer_code,
            ip_address: "127.0.0.1"
          )
        }.to raise_error(ArgumentError)
      end

      it "raises an error with invalid currency" do
        expect {
          connection.purchase(
            amount: rand(100..10000) / 100.0,
            currency: "INVALID",
            card_token: card_token,
            customer_code: customer_code,
            ip_address: "127.0.0.1"
          )
        }.to raise_error(HelcimRuby::Error)
      end

      it "raises an error with negative amount" do
        expect {
          connection.purchase(
            amount: -(rand(100..10000) / 100.0),
            card_token: card_token,
            customer_code: customer_code,
            ip_address: "127.0.0.1"
          )
        }.to raise_error(HelcimRuby::Error)
      end
    end
  end

  describe "#preauth", :vcr do
    context "with card token" do
      it "processes a preauth with valid card token" do
        response = connection.preauth(
          amount: test_amount,
          currency: "USD",
          card_token: card_token,
          customer_code: customer_code,
          ip_address: "127.0.0.1"
        )

        expect(response).to be_a(HelcimRuby::PaymentTransaction)
        expect(response.status).to eq("APPROVED")
        expect(response.transaction_id).to_not be_nil
        expect(response.amount).to be_a(Numeric)
      end
    end

    context "with invalid data" do
      it "raises an error with missing required fields" do
        expect {
          connection.preauth(
            amount: nil,
            card_token: card_token,
            ip_address: "127.0.0.1"
          )
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#capture" do
    # NOTE: Using mocks to ensure consistent amount handling
    let(:amount) { 25.50 }
    let(:transaction_id) { "33865254" }
    let(:client) { instance_double(HelcimRuby::Client) }
    let(:connection) { described_class.new(client) }
    let(:mock_response) do
      instance_double(
        HTTParty::Response,
        code: 200,
        body: {
          transactionId: transaction_id,
          status: "APPROVED",
          amount: amount,
          type: "capture"
        }.to_json
      )
    end

    before do
      allow(client).to receive(:default_headers).and_return({ "api-token" => "test-token" })
      allow(client).to receive(:class).and_return(HTTParty)
      allow(SecureRandom).to receive(:uuid).and_return("091d7c42-5bdc-4e74-9062-5")
    end

    it "captures a preauthorized transaction" do
      expect(HTTParty).to receive(:post).with(
        "/payment/capture",
        {
          headers: {
            "api-token" => "test-token",
            "idempotency-key" => "091d7c42-5bdc-4e74-9062-5"
          },
          body: {
            preAuthTransactionId: transaction_id,
            amount: amount,
            currency: "USD",
            ipAddress: "127.0.0.1"
          }.to_json
        }
      ).and_return(mock_response)

      response = connection.capture(
        transaction_id: transaction_id,
        amount: amount,
        ip_address: "127.0.0.1"
      )

      expect(response).to be_a(HelcimRuby::PaymentTransaction)
      expect(response.status).to eq("APPROVED")
      expect(response.transaction_id).to eq(transaction_id)
      expect(response.amount).to eq(amount)
    end

    it "raises an error with missing transaction_id" do
      expect {
        connection.capture(
          transaction_id: nil,
          amount: amount
        )
      }.to raise_error(ArgumentError)
    end
  end

  describe "#refund", :vcr do
    # NOTE: Development batches can not be settled. We have to mock the response.
    let(:client) { instance_double(HelcimRuby::Client) }
    let(:connection) { described_class.new(client) }
    let(:mock_response) do
      instance_double(
        HTTParty::Response,
        code: 200,
        body: {
          transactionId: "33865254",
          status: "APPROVED",
          amount: 10.00,
          type: "refund"
        }.to_json
      )
    end

    before do
      allow(client).to receive(:default_headers).and_return({ "api-token" => "test-token" })
      allow(client).to receive(:class).and_return(HTTParty)
    end

    it "processes a refund for a transaction" do
      expect(HTTParty).to receive(:post).with(
        "/payment/refund",
        {
          headers: hash_including("api-token" => "test-token"),
          body: {
            originalTransactionId: "33865254",
            amount: 10.00,
            currency: "USD",
            ipAddress: "127.0.0.1"
          }.to_json
        }
      ).and_return(mock_response)

      response = connection.refund(
        transaction_id: "33865254",
        amount: 10.00,
        ip_address: "127.0.0.1"
      )

      expect(response).to be_a(HelcimRuby::PaymentTransaction)
      expect(response.status).to eq("APPROVED")
      expect(response.transaction_id).to eq("33865254")
      expect(response.amount).to eq(10.00)
    end

    context "with invalid data" do
      it "raises an error with missing transaction_id" do
        expect {
          connection.refund(
            transaction_id: nil,
            amount: 10.00
          )
        }.to raise_error(ArgumentError)
      end

      it "raises an error with missing amount" do
        expect {
          connection.refund(
            transaction_id: "33865254",
            amount: nil
          )
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#reverse" do
    # NOTE: Like refunds, reversals need a real transaction to test against.
    # The difference is that reversals work on transactions in open batches,
    # while refunds require settled batches.
    let(:client) { instance_double(HelcimRuby::Client) }
    let(:connection) { described_class.new(client) }
    let(:mock_response) do
      instance_double(
        HTTParty::Response,
        code: 200,
        body: {
          transactionId: reverse_transaction_id,
          status: "APPROVED",
          type: "reverse"
        }.to_json
      )
    end

    before do
      allow(client).to receive(:default_headers).and_return({ "api-token" => "test-token" })
      allow(client).to receive(:class).and_return(HTTParty)
      allow(SecureRandom).to receive(:uuid).and_return("091d7c42-5bdc-4e74-9062-5")
    end

    it "reverses a transaction" do
      expect(HTTParty).to receive(:post).with(
        "/payment/reverse",
        {
          headers: {
            "api-token" => "test-token",
            "idempotency-key" => "091d7c42-5bdc-4e74-9062-5"
          },
          body: {
            cardTransactionId: reverse_transaction_id,
            ipAddress: "127.0.0.1"
          }.to_json
        }
      ).and_return(mock_response)

      response = connection.reverse(
        transaction_id: reverse_transaction_id,
        ip_address: "127.0.0.1"
      )

      expect(response).to be_a(HelcimRuby::PaymentTransaction)
      expect(response.status).to eq("APPROVED")
      expect(response.transaction_id).to eq(reverse_transaction_id)
    end

    it "raises an error with missing transaction_id" do
      expect {
        connection.reverse(transaction_id: nil)
      }.to raise_error(ArgumentError)
    end
  end
end 