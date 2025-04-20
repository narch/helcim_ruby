# frozen_string_literal: true

FactoryBot.define do
  factory :customer, class: Hash do
    contact_name { "John Doe" }
    business_name { "Sample Business" }
    cell_phone { "0987654321" }
    
    initialize_with { attributes }
  end
end 