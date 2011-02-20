Interpret.configure do |config|
  config.sweeper = "page_sweeper"
  config.registered_envs = [:production, :development]
  config.parent_controller = "application_controller"
  config.current_user = "current_user"
  config.admin = "admin?"
  config.layout = "layouts/application"
end
