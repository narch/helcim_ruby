require "spec_helper"

RSpec.describe HelcimRuby::Resources::Cards do
  # Refer to README.md for testing environment setup.
  # These values need to be updated if re-recording the VCR cassette
  let(:customer_id) { "28630702" }
  let(:card_id) { "27567085" }
  let(:delete_card_id) { "27602363" }

  let(:client) { HelcimRuby::Client.new(ENV["HELCIM_API_TOKEN"]) }
  let(:cards) { client.cards(customer_id) }
  let(:customer_attributes) { attributes_for(:customer) }

  describe "#list", :vcr do
    context "when customer has no transactions" do
      let(:new_customer) do
        client.customers.create(
          contact_name: customer_attributes[:contact_name],
          business_name: customer_attributes[:business_name]
        )
      end

      it "returns empty collection when customer has no cards" do
        cards_list = client.cards(new_customer.id).list
        expect(cards_list).to be_a(HelcimRuby::Collection)
        expect(cards_list.data).to be_empty
      end
    end

    context "when customer has cards" do
      it "retrieves the customer's cards" do
        cards_list = cards.list
        expect(cards_list).to be_a(HelcimRuby::Collection)
        expect(cards_list.data).not_to be_empty
        expect(cards_list.data.first).to be_a(HelcimRuby::Card)
        expect(cards_list.data.first.card_f6_l4).to end_with("9990") # Last 4 of test card
      end
    end

    it "raises an error with invalid customer id" do
      expect {
        client.cards("INVALID123").list
      }.to raise_error(HelcimRuby::Error)
    end
  end

  describe "#set_default", :vcr do
    it "sets the card as default" do
      card = cards.set_default(card_id)
      expect(card).to be_a(HelcimRuby::Card)
    end

    it "raises an error with invalid customer id" do
      expect {
        client.cards("invalid_id").set_default(card_id)
      }.to raise_error(HelcimRuby::Error)
    end

    it "raises an error with invalid card id" do
      expect {
        cards.set_default("invalid_card_id")
      }.to raise_error(HelcimRuby::Error)
    end
  end

  describe "#destroy", :vcr do
    it "deletes the card" do
      result = cards.destroy(delete_card_id)
      expect(result).to be true
    end

    # the card should no longer exist
    context "when card does not exist" do
      it "raises an error" do
        expect {
          cards.destroy(delete_card_id)
        }.to raise_error(HelcimRuby::Error)
      end
    end
  end
end