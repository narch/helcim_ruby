# frozen_string_literal: true

require "dotenv/load"
require "vcr"
require "webmock/rspec"
require "factory_bot"
require "helcim_ruby"

# Configure FactoryBot
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end
end

VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!

  # Filter API token
  config.filter_sensitive_data("<API_TOKEN>") { ENV["HELCIM_API_TOKEN"] }

  # Allow real HTTP connections when no cassette exists (for initial recording)
  config.default_cassette_options = { record: :once }
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
end
