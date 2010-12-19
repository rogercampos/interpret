require 'i18n/backend/active_record'
require 'interpret/logger'

module Interpret
  class Engine < Rails::Engine
    if Rails.env == "production"
      initializer "interpret.register_i18n_active_record_backend" do |app|
        I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Memoize)
        I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Flatten)

        Interpret.backend = I18n::Backend::ActiveRecord.new
        app.config.i18n.backend = Interpret.backend
      end
    end

    initializer "interpret.setup_translations_logger" do |app|
      logfile = File.open("#{Rails.root}/log/interpret.log", 'a')
      logfile.sync = true
      Interpret.logger = InterpretLogger.new(logfile)
    end
  end
end
