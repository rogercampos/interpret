namespace :interpret do
  desc 'Copy all the translations in files from config/locales/*.yml into DB backend'
  task :migrate => :environment do
    files = Dir[Rails.root.join("config", "locales", "*.yml").to_s]
    files.each do |f|
      ar = YAML.load_file f
      locale = ar.keys.first
      parse_hash(ar.first[1], locale)
    end
  end

  desc 'Synchronize the keys used in db backend with the ones on *.yml files'
  task :update => :environment do
    files = Dir[Rails.root.join("config", "locales", "*.yml").to_s]

    languages = []
    reference_hash = {}
    files.each do |f|
      ar = YAML.load_file f
      locale = ar.keys.first
      languages << locale

      reference_hash = ar.first[1] if I18n.default_locale.to_sym == locale.to_sym
    end

    languages.each do |x|
      put_in_sync_with_db(reference_hash, x)
    end

    puts "Updated Translations table."
  end
end


def get_value_from_yaml_by_ckey(locale, ckey)
  old_backend = I18n.backend
  I18n.backend = I18n::Backend::Simple.new
  old = I18n.locale
  I18n.locale = locale
  res = I18n.t(ckey)
  I18n.locale = old
  I18n.backend = old_backend
  res
end

# Fem que les claus a bd pel locale donat corresponguin al hash original de contrast dict
def put_in_sync_with_db(dict, locale, prefix = "", existing = nil)
  if existing.nil?
    existing = Translation.hash_from_query(:locale => locale)
    existing = existing.first[1] unless existing.empty?
  end

  dict.keys.each do |x|
    existing.delete(x)

    if dict[x].kind_of?(Hash)
      put_in_sync_with_db(dict[x], locale, "#{prefix}#{x}.", existing[x])
    else
      old = Translation.where(:locale => locale, :key => "#{prefix}#{x}").first
      if !old
        Translation.create :locale => locale,
                           :key => "#{prefix}#{x}",
                           :value => get_value_from_yaml_by_ckey(locale, "#{prefix}#{x}")
        TRANSLATION_LOGGER.info("[translations:update] Created new key for locale: [#{locale}], key: [#{prefix}#{x}]")
      end
    end
  end

  if prefix.blank?
    remove_old_keys_in_db(existing, locale)
  end
end

def remove_old_keys_in_db(dict, locale, prefix = "")
  dict.keys.each do |x|
    if dict[x].kind_of?(Hash)
      remove_old_keys_in_db(dict[x], locale, "#{prefix}#{x}.")
    else
      old = Translation.where(:locale => locale, :key => "#{prefix}#{x}").first
      TRANSLATION_LOGGER.info("[translations:update] Removed unused key [#{prefix}#{x}] for locale [#{locale}]. The value was [#{old.value}]")
      old.delete
    end
  end
end


def parse_hash(dict, locale, prefix = "")
  dict.keys.each do |x|
    if dict[x].kind_of?(Hash)
      parse_hash(dict[x], locale, "#{prefix}#{x}.")
    else
      old = Interpret::Translation.where(:locale => locale, :key => "#{prefix}#{x}").first
      if old
        old.value = dict[x]
        old.save!
        puts "Updated value for: #{locale} -> #{prefix}#{x}"
      else
        Interpret::Translation.create :locale => locale,
                           :key => "#{prefix}#{x}",
                           :value => dict[x]
        puts "New translation for: #{locale} -> #{prefix}#{x}"
      end
    end
  end
end

