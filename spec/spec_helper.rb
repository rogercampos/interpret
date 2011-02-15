# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path('../../test_app/config/environment', __FILE__)
require "rails/test_help"
require "rspec/rails"
require "database_helpers"

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

include DatabaseHelpers
# Run any available migration
puts 'Setting up database...'
drop_all_tables
migrate_database

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each{|f| require f}


RSpec.configure do |config|
  # Remove this line if you don't want RSpec's should and should_not
  # methods or matchers
  require 'rspec/expectations'

  config.include RSpec::Matchers
  config.include DatabaseHelpers

  # == Mock Framework
  config.mock_with :rspec
end
