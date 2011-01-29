require 'rails/generators/migration'

module Interpret

  class MigrationGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    source_root File.expand_path("../templates", __FILE__)

    desc "Creates the migration for i18n activerecord backend translations table"

    def self.next_migration_number(dirname)
      if ActiveRecord::Base.timestamped_migrations
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      else
        "%.3d" % (current_migration_number(dirname) + 1)
      end
    end

    def copy_translations_migration
      migration_template "migration.rb", "db/migrate/interpret_create_translations.rb"
    end

  end
end

