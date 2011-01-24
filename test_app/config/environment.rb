# Load the rails application
require File.expand_path('../application', __FILE__)

require "#{Rails.root}/config/setup_app"

# Initialize the rails application
InterpretApp::Application.initialize!
