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
        lazy = lambda { |h,k| h[k] = Hash.new(&lazy) }
        res = Hash.new(&lazy)

        translations.each do |e|
          asign_value(res, "#{e.locale}.#{e.key}", e.value)
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

    private
      def asign_value(hash, key, value, pre = nil)
        skeys = key.split(".")
        f = skeys.shift
        if skeys.empty?
          pre.send("[]=", f, value)
        else
          if pre.nil?
            pre = hash.send("[]", f)
          else
            pre = pre.send("[]", f)
          end
          asign_value(hash, skeys.join("."), value, pre)
        end
      end
    end
  end
end

