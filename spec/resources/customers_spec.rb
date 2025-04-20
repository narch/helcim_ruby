# frozen_string_literal: true

require "spec_helper"

RSpec.describe HelcimRuby::Resources::Customers do
  let(:client) { HelcimRuby::Client.new(ENV["HELCIM_API_TOKEN"]) }
  let(:connection) { described_class.new(client) }
  let(:customer_attributes) { attributes_for(:customer) }
  let(:payment) { HelcimRuby::Resources::Payment.new(client) }

  # Refer to README.md for testing environment setup.
  # These values need to be updated if re-recording the VCR cassette
  let(:customer_code) { "CST1146" }
  let(:customer_id) { "28630702" }
  let(:card_id) { "27567085" }
  let(:delete_card_id) { "27575187" }

  describe "#list", :vcr do
    it "returns a list of customers" do
      response = connection.list(customer_code: customer_code, limit: 1)
      expect(response).to be_a(HelcimRuby::Collection)
      expect(response.data.first).to be_a(HelcimRuby::Customer)
      expect(response.data.first.customer_code).to eq(customer_code)
    end

    it "returns a list of customers with cards" do
      response = connection.list(customer_code: customer_code, limit: 1, include_cards: "yes")
      expect(response).to be_a(HelcimRuby::Collection)
      expect(response.data.first).to be_a(HelcimRuby::Customer)
      expect(response.data.first.customer_code).to eq(customer_code)
      expect(response.data.first.cards).to be_an(Array)
      expect(response.data.first.cards).not_to be_empty
    end

    it "returns matching customers by search term" do
      results = connection.list(customer_code: customer_code)
      expect(results).to be_a(HelcimRuby::Collection)
      expect(results.data.first).to be_a(HelcimRuby::Customer)
      expect(results.data.first.id).not_to be_nil
      expect(results.data.first.customer_code).not_to be_nil
    end

    it "returns empty collection when no matches found" do
      results = connection.list(search: "NonexistentCustomer12345")
      expect(results).to be_a(HelcimRuby::Collection)
      expect(results.data).to be_empty
    end
  end

  describe "#create", :vcr do
    it "creates a new customer with contact name" do
      response = connection.create(
        contact_name: customer_attributes[:contact_name],
        cellphone: "0987654321"
      )

      expect(response).to be_a(HelcimRuby::Customer)
      expect(response.id).not_to be_nil
      expect(response.contact_name).to eq(customer_attributes[:contact_name])
      expect(response.cellphone).to eq("0987654321")
    end

    it "creates a new customer with business name" do
      response = connection.create(
        business_name: "Test Company LLC"
      )

      expect(response).to be_a(HelcimRuby::Customer)
      expect(response.id).not_to be_nil
      expect(response.business_name).to eq("Test Company LLC")
    end

    it "creates a customer with billing address" do
      response = connection.create(
        contact_name: customer_attributes[:contact_name],
        billing_address: {
          name: customer_attributes[:contact_name],
          street1: "123 Main St",
          street2: "Suite 101",
          city: "New York",
          province: "NY",
          country: "USA",
          postal_code: "10001"
        }
      )

      expect(response.billing_address.name).to eq(customer_attributes[:contact_name])
      expect(response.billing_address.street1).to eq("123 Main St")
      expect(response.billing_address.street2).to eq("Suite 101")
      expect(response.billing_address.city).to eq("New York")
      expect(response.billing_address.province).to eq("NY")
      expect(response.billing_address.country).to eq("USA")
      expect(response.billing_address.postal_code).to eq("10001")
    end

    it "creates a customer with shipping address" do
      response = connection.create(
        contact_name: customer_attributes[:contact_name],
        shipping_address: {
          name: customer_attributes[:contact_name],
          street1: "456 Ship St",
          city: "Los Angeles",
          province: "CA",
          country: "USA",
          postal_code: "90001"
        }
      )

      expect(response.shipping_address.name).to eq(customer_attributes[:contact_name])
      expect(response.shipping_address.street1).to eq("456 Ship St")
      expect(response.shipping_address.city).to eq("Los Angeles")
      expect(response.shipping_address.province).to eq("CA")
      expect(response.shipping_address.country).to eq("USA")
      expect(response.shipping_address.postal_code).to eq("90001")
    end

    it "raises an error when neither contact_name nor business_name is provided" do
      expect do
        connection.create(
          cellphone: "1234567890"
        )
      end.to raise_error(HelcimRuby::Error)
    end

    it "raises an error with invalid data" do
      expect do
        connection.create(
          contact_name: "",
          business_name: ""
        )
      end.to raise_error(HelcimRuby::Error)
    end
  end

  describe "#get", :vcr do
    let(:customer) do
      connection.create(
        contact_name: customer_attributes[:contact_name],
        business_name: customer_attributes[:business_name]
      )
    end

    it "retrieves a customer by ID" do
      response = connection.get(customer.id)

      expect(response).to be_a(HelcimRuby::Customer)
      expect(response.id).to eq(customer.id)
      expect(response.business_name).to eq(customer_attributes[:business_name])
      expect(response.contact_name).to eq(customer_attributes[:contact_name])
    end

    it "raises an error with invalid customer ID" do
      expect do
        connection.get(0)
      end.to raise_error(HelcimRuby::Error)
    end
  end

  describe "#update", :vcr do
    let(:customer) do
      connection.create(
        contact_name: customer_attributes[:contact_name],
        business_name: customer_attributes[:business_name]
      )
    end

    it "updates a customer" do
      new_contact_name = "Updated Contact Name"
      response = connection.update(
        customer.id,
        contactName: new_contact_name
      )

      expect(response).to be_a(HelcimRuby::Customer)
      expect(response.id).to eq(customer.id)
      expect(response.contact_name).to eq(new_contact_name)
    end

    it "raises an error with invalid data" do
      expect do
        connection.update(customer.id, contact_name: "")
      end.to raise_error(HelcimRuby::Error)
    end
  end
end
