require 'i18n/backend/active_record/translation'


module Interpret

  class TableDoesNotExists < ActiveRecord::ActiveRecordError; end

  unless I18n::Backend::ActiveRecord::Translation.table_exists?
    raise TableDoesNotExists, "You must setup a translations table first"
  end

  class Translation < I18n::Backend::ActiveRecord::Translation
    default_scope order('locale ASC')

    class << self
      def as_hash(translations)
        res = LazyHash.build_hash

        translations.each do |e|
          LazyHash.lazy_add(res, "#{e.locale}.#{e.key}", e.value)
        end
        res
      end

      def update_from_hash(locale, hash, prefix = "")
        changes = 0
        hash.keys.each do |x|
          if hash[x].kind_of?(Hash)
            changes = changes + update_from_hash(locale, hash[x], "#{prefix}#{x}.")
          else
            old = where(:locale => locale, :key => "#{prefix}#{x}").first
            if old && old.value != hash[x]
              aux = old.value
              old.update_attribute :value, hash[x]
              #TRANSLATION_LOGGER.info("[manual YAML file locale upload] Updated value for: #{locale}, #{prefix}#{x} from [#{aux}] to [#{hash[x]}]")
              changes += 1
            end
          end
        end
        changes
      end

      # Import all contents from *.yml locale files into the database.
      # CAUTION: All existing data will be erased!
      #
      # It will create a "#{locale}.yml.backup" file into config/locales
      # for each language present in the database, in case you want to
      # recover some of your just-erased translations.
      # If you don't want backups, set:
      #
      # Interpret.options[:no_backup] = true
      def import
        files = Dir[Rails.root.join("config", "locales", "*.yml").to_s]
        files.each do |f|
          ar = YAML.load_file f
          locale = ar.keys.first
          parse_hash(ar.first[1], locale)
        end
      end

      def parse_hash(dict, locale, prefix = "")
        dict.keys.each do |x|
          if dict[x].kind_of?(Hash)
            parse_hash(dict[x], locale, "#{prefix}#{x}.")
          else
            old = where(:locale => locale, :key => "#{prefix}#{x}").first
            if old
              old.value = dict[x]
              old.save!
              puts "Updated value for: #{locale} -> #{prefix}#{x}"
            else
              create! :locale => locale,
                      :key => "#{prefix}#{x}",
                      :value => dict[x]
              puts "New translation for: #{locale} -> #{prefix}#{x}"
            end
          end
        end
      end
    end
  end
end

