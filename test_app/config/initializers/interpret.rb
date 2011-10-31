Interpret.configure do |config|
  config.registered_envs << :development
  config.parent_controller = "application_controller"
  config.layout = "backoffice"
  config.scope = "(:locale)"
  config.ability = "interpret_ability"
  config.black_list = ["blacklist.*"]
end
