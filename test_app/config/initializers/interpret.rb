Interpret.configure do |config|
  config.registered_envs << :development
  config.parent_controller = "application_controller"
  config.current_user = "current_user"
  config.admin = "admin?"
  config.layout = "backoffice"
  config.scope = "(:locale)"
end
