Interpret.configure do |config|
  config.registered_envs = [:production, :development]
  config.parent_controller = "application_controller"
  config.current_user = "current_user"
  config.admin = "admin?"
  config.layout = "application"
  #config.sweeper = "my_sweeper"
  config.live_edit = true
end
