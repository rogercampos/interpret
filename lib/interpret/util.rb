module Interpret
  def update_locale_from_hash(locale, dict, prefix = "")
    changes = 0
    dict.keys.each do |x|
      if dict[x].kind_of?(Hash)
        changes = changes + update_locale_from_hash(locale, dict[x], "#{prefix}#{x}.")
      else
        old = Translation.where(:locale => locale, :key => "#{prefix}#{x}").first
        if old && old.value != dict[x]
          aux = old.value
          old.update_attribute :value, dict[x]
          TRANSLATION_LOGGER.info("[manual YAML file locale upload] Updated value for: #{locale}, #{prefix}#{x} from [#{aux}] to [#{dict[x]}]")
          changes = changes + 1
        end
      end
    end
    changes
  end

end
