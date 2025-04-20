# frozen_string_literal: true

FactoryBot.define do
  factory :payment_card, class: Hash do
    card_holder_name { "John Doe" }
    card_expiry { "0128" }  # All test cards use 01/28
    card_cvv { "100" }      # All test cards use 100 except AMEX which uses 1000

    trait :mastercard do
      card_number { "5413330089099130" }
    end

    trait :visa do
      card_number { "4124939999999990" }
    end

    trait :amex do
      card_number { "374245001751006" }
      card_cvv { "1000" }  # AMEX uses 4-digit CVV
    end

    trait :discover do
      card_number { "6011973700000005" }
    end

    # Billing details trait with minimum required fields
    trait :with_billing do
      billing_contact_name { "John Doe" }
      billing_street1 { "123 Main St" }
      billing_postal_code { "10001" }
    end

    # Full billing details trait
    trait :with_full_billing do
      billing_contact_name { "John Doe" }
      billing_street1 { "123 Main St" }
      billing_street2 { "Suite 456" }
      billing_city { "New York" }
      billing_province { "NY" }
      billing_country { "USA" }
      billing_postal_code { "10001" }
      billing_phone { "2125551234" }
      billing_email { "john.doe@example.com" }
    end

    initialize_with { attributes }
  end
end 