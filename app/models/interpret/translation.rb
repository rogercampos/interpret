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
              changes = changes + 1
            end
          end
        end
        changes
      end
    end
  end
end

