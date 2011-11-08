# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path('../../test_app/config/environment.rb', __FILE__)
require "rspec/rails"
require 'yaml'

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each{|f| require f}

RSpec.configure do |config|
  config.include BestInPlace::TestHelpers

  config.use_transactional_fixtures = true
end
