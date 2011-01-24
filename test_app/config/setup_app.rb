if ENV['HEROKU'].present?
  keys = [:name,
          :hostname,
          :exception_notification_sender,
          :exception_notification_recipients,
          :mail__user_name,
          :mail__password,
          :mail__smtp__address,
          :mail__smtp__port,
          :mail__domain
         ]

  require 'lazy_hash'
  APP_CONFIG = LazyHash.build_hash

  keys.each do |key|
    LazyHash.lazy_add(APP_CONFIG, key.to_s.split("__").join("."), ENV[key.to_s.upcase])
  end

else
  APP_CONFIG = YAML.load_file("#{Rails.root}/config/app.yml")[Rails.env]

end

