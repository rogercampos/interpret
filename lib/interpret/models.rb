module Interpret
  class Translation < I18n::Backend::ActiveRecord::Translation
    default_scope order('locale ASC')

    def self.as_hash(translations)
      lazy = lambda { |h,k| h[k] = Hash.new(&lazy) }
      res = Hash.new(&lazy)

      translations.each do |e|
        asign_value(res, "#{e.locale}.#{e.key}", e.value)
      end
      res
    end

  private
    def self.asign_value(hash, key, value, pre = nil)
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
