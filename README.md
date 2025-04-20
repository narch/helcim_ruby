# HelcimRuby

A Ruby gem for integrating with the Helcim Commerce API. This gem provides a simple interface for processing payments, managing customers, and handling card operations with Helcim's payment platform.

> [!IMPORTANT]  
> - **Card Tokens Only:** helcim_ruby supports payments using cardToken values obtained via Helcim.js or HelcimPay.js tokenization. Full card numbers, expiry dates, and CVV codes are not supported by this gem, aligning with Helcim's default API security restrictions.
> - **Tokenization Requirement:** Helcim requires cards to be tokenized client-side (e.g., using Helcim.js) before sending to the API. This gem does not handle tokenization—it expects a pre-tokenized cardToken from your frontend integration. See [Helcim.js](https://devdocs.helcim.com/docs/helcimjs-implementation) Implementation for details.
> - **PCI Compliance:** Sending full card details directly to the API is only allowed for merchants approved for PCI DSS SAQ-D compliance. If your account supports this, you'll need to modify the gem's Payment resource accordingly—this gem's default implementation does not include this capability.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'helcim_ruby'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install helcim_ruby
```

## Configuration

### Rails

Create an initializer at `config/initializers/helcim.rb`:

```ruby
HelcimRuby.configure do |config|
  config.api_token = ENV["HELCIM_API_TOKEN"]        # Required: Your Helcim API token
  config.default_currency = "USD"                    # Optional: Default currency for transactions (defaults to USD)
  config.base_uri = "https://api.helcim.com/v2"     # Optional: API endpoint (defaults to production)
end
```

### Non-Rails

Initialize the client with your API token:

```ruby
client = HelcimRuby::Client.new(ENV["HELCIM_API_TOKEN"])
```

## Usage

### Customer Management

Create and manage customers:

```ruby
# Initialize the Customers resource
customers = HelcimRuby::Resources::Customers.new(client)

# Create a new customer
# Note: Either contact_name OR business_name is required

# Minimal
customer = customers.create(contact_name: "John Doe")

# All params
customer = customers.create(
  contact_name: "John Doe",      # Required if business_name is not present
  business_name: "ACME Corp",    # Required if contact_name is not present
  cell_phone: "1234567890",      # Optional
  customer_code: "CUS123",       # Optional (if blank, it will be automatically generated.)
  billing_address: {             # Optional
    street1: "123 Main St",
    street2: "Suite 101",        # Optional
    city: "New York",
    province: "NY",
    country: "US",
    postal_code: "10001"
  },
  shipping_address: {            # Optional
    street1: "123 Main St",
    street2: "Suite 101",        # Optional
    city: "New York",
    province: "NY",
    country: "US",
    postal_code: "10001"
  }
)

# Get customer by ID
customer = customers.get("12345")

# Search for customers
results = customers.search(
  customer_code: "CST1234",     # Optional: Search by customer code
  search: "John Doe",           # Optional: Search by any field
  limit: 10,                    # Optional: Limit results (default varies)
  page: 1,                      # Optional: Page number for pagination
  include_cards: "yes"          # Optional: Include card information
)

# Update customer
updated_customer = customers.update(
  "12345",                      # Customer ID
  contact_name: "Jane Doe"
)

# Get customer's cards
cards = customers.get_cards("12345")  # Customer ID

# Set default card
customers.set_default_card("12345", "card_id_123")  # Customer ID, Card ID

# Delete a card
customers.destroy_card("12345", "card_id_123")  # Customer ID, Card ID
```

### Payment Processing

Process payments using card tokens:

```ruby
# Initialize the Payment resource
payment = HelcimRuby::Resources::Payment.new(client)

# Process a purchase with a card token
response = payment.purchase(
  amount: 99.99,                      # Required
  card_token: "customers_card_token", # Required
  ip_address: "127.0.0.1",            # Required (customers IP address)
  currency: "USD",                    # Optional (defaults to configuration)
  customer_code: "CST1234",           # Optional: Associate with a customer
  ecommerce: true                     # Optional (defaults to true)
)

# The response will include:
# {
#   "transactionId": "12345",          # Unique transaction identifier
#   "type": "purchase",                # Transaction type
#   "date": "2024-01-01 12:00:00",     # Transaction date
#   "amount": "99.99",                 # Transaction amount
#   "currency": "USD",                 # Transaction currency
#   "cardHolderName": "John Doe",      # Card holder's name
#   "cardNumber": "411111...1111",     # Masked card number
#   "cardExpiry": "0125",              # Card expiry date
#   "cardToken": "abc123...",          # Card token for future transactions
#   "cardType": "visa",                # Card type/brand
#   "responseCode": "0",               # Response code (0 = approved)
#   "responseMessage": "APPROVED",     # Response message
#   "notice": "Transaction approved",  # Additional notice
#   "avsResponse": "Y",                # Address verification response
#   "cvvResponse": "M",                # CVV verification response
#   "approvalCode": "123456",          # Bank approval code
#   "orderNumber": "INV-123",          # Your order/invoice number if provided
#   "customerCode": "CST1234"          # Customer code if provided
# }

# Check the response
if response["responseCode"] == "0"
  puts "Transaction approved! ID: #{response['transactionId']}"
  puts "Auth code: #{response['approvalCode']}"
else
  puts "Transaction failed: #{response['responseMessage']}"
end
```

## Contributing

Thank you for your interest in contributing to helcim_ruby! At this time, i'm not accepting pull requests as the gem is under active internal development. However, I still encourage you to report any bugs or issues you encounter by opening an issue on GitHub at https://github.com/narch/helcim_ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
