require 'i18n/backend/active_record/translation'


module Interpret

  class TableDoesNotExists < ActiveRecord::ActiveRecordError; end

  unless I18n::Backend::ActiveRecord::Translation.table_exists?
    raise TableDoesNotExists, "You must setup a translations table first"
  end

  class Translation < I18n::Backend::ActiveRecord::Translation
    default_scope order('locale ASC')

    class << self
      # Generates a hash representing the tree structure of the translations
      # for the given locale. It includes only "folders" in the sense of
      # locale keys that includes some real translations, or other keys.
      def get_tree(lang = I18n.default_locale)
        t = arel_table
        all_trans = locale(lang).select(t[:key]).where(t[:key].matches("%.%")).all

        tree = LazyHash.build_hash
        all_trans = all_trans.map{|x| x.key.split(".")[0..-2].join(".")}.uniq
        all_trans.each do |x|
          LazyHash.lazy_add(tree, x, {})
        end

        # Generate a new clean hash without the proc's from LazyHash.
        # Includes a root level for convenience, to be exactly like the
        # structure of a .yml file which has the "en" root key for example.
        {"index" => eval(tree.inspect)}
      end

      # Generate a hash from the given translations. That hash can be
      # ya2yaml'ized to get a standard .yml locale file.
      def export(translations)
        res = LazyHash.build_hash

        translations.each do |e|
          LazyHash.lazy_add(res, "#{e.locale}.#{e.key}", e.value)
        end
        if res.keys.size != 1
          raise IndexError, "Generated hash must have only one root key. Your translation data in datrabase may be corrupted."
        end
        res
      end

      # Import the contents of the given .yml locale file into the database
      # backend. All the existing translations for the given language will be
      # erased, the backend will contain only the translations from the file
      # (in that language).
      #
      # The language will be obtained from the first unique key of the yml
      # file.
      def import(file)
        if file.content_type && file.content_type.match(/^text\/.*/).nil?
          raise ArgumentError, "Invalid file content type"
        end
        hash = YAML.load file
        raise ArgumentError, "the YAML file must contain an unique first key representing the locale" unless hash.keys.count == 1

        lang = hash.keys.first
        delete_all(:locale => lang)

        records = parse_hash(hash.first[1], lang)
        # TODO: Replace with activerecord-import bulk inserts
        transaction do
          records.each do |x|
            a = create! :locale => x.locale, :key => x.key, :value => x.value
            puts x.value
            a.update_attribute :value, x.value.to_s
            a.reload
            puts a.inspect
          end
        end
      end

      # Dump all contents from *.yml locale files into the database.
      # CAUTION: All existing data will be erased!
      #
      def dump
        files = Dir[Rails.root.join("config", "locales", "*.yml").to_s]
        delete_all

        records = []
        files.each do |f|
          ar = YAML.load_file f
          locale = ar.keys.first
          records += parse_hash(ar.first[1], locale)
        end

        # TODO: Replace with activerecord-import bulk inserts
        transaction do
          records.each {|x| x.save!}
        end
      end

      # Run a smart update from the translations in .yml files into the
      # databse backend. It issues a merging from both, comparing each key
      # present in the db with the one from the yml file.
      #
      # The use case beyond this arquitecture presuposes some things:
      #
      # 1) You're working in development mode with the default I18n backend,
      # that is with the translations in the config/locales/*.yml files.
      #
      # 2) Your application is deployed in production and running well. Also,
      # it has support to modify it's contents (from this very gem of course)
      # on live, so its possible that your customer has changed a sentence or
      # a title of the site. And you want to preserve that.
      #
      # 3) In general, from the very moment you choose to give the users (or
      # admins) of your site the ability to change the contents, that contents
      # are no longer part of the "project" (are checked in in git, to be
      # specific), they are now part of the dynamic contents of the site just
      # as if they were models in your db.
      #
      # In development, you define a "content layout" in the sense of a
      # specific locale keys hierarchy. How many paragraphs are in your views,
      # how many titles, etc... But the real paragraphs are in the production
      # database.
      #
      # So, with this "update" action, you are updating that "contents layout"
      # with the new one you just designed in development.
      #
      # Also keep in mind that rails let you have a diferent locale key
      # hierarchy for each language, and this behaviour is prohibited in
      # interpret.
      # Here, the I18n.default_locale configured in your app is considered the
      # main one, that is, the only language that can be trusted to have all
      # the required and correct locale keys.
      # This will be used to check for inconsitent translations into other
      # languages, knowing what you haven't translated yet.
      #
      # What does all that means?
      #
      # - First of all, get the locale keys for the main language from yml files.
      # - For all of these locale keys, do:
      #   - If the key is not present in the db, it's new. So, create a new
      #   entry for that key in the main language. If the key also exists in
      #   some other languages in yml files, also create the entry for that
      #   languages. But, do not create entries for the languages that does
      #   not have this key. Later you will be notified about that missing
      #   translations.
      #   - If the key already exists in the db, do nothing. Maybe somone has
      #   changed that content in production, and you don't want to lose
      #   that. Or maybe you do want to change that content, because you
      #   just added the correct sentence in the yml files. It's up to you to
      #   do the right thing.
      #   Also, if the key is missing in other languages in database but
      #   present in yml files, create the new entry for that language.
      #   - If a key is present in the db, but not in the new ones, remove
      #   it. You have removed it from the new content layout, so it's no longer
      #   needed.
      #
      def update
        files = Dir[Rails.root.join("config", "locales", "*.yml").to_s]

        @languages = {}
        files.each do |f|
          ar = YAML.load_file f
          lang = ar.keys.first
          if @languages.has_key?(lang.to_s)
            @languages[lang.to_s] = @languages[lang.to_s].deep_merge(ar.first[1])
          else
            @languages[lang.to_s] = ar.first[1]
          end
        end

        sync(@languages[I18n.default_locale.to_s])
      end

    private
      def sync(hash, prefix = "", existing = nil)
        if existing.nil?
          translations = locale(I18n.default_locale).all
          existing = export(translations)
          existing = existing.first[1] unless existing.empty?
        end

        hash.keys.each do |x|
          if hash[x].kind_of?(Hash)
            sync(hash[x], "#{prefix}#{x}.", existing[x])
          else
            existing.delete(x)
            old = locale(I18n.default_locale).find_by_key("#{prefix}#{x}")

            unless old
              # Creates the new entry
              create_new_translation("#{prefix}#{x}", hash[x])
            else
              # Check if the entry exists in the other languages
              check_in_other_langs("#{prefix}#{x}")
            end
          end
        end

        if prefix.blank?
          remove_unused_keys(existing)
        end
      end

      # Check if the given key exists in @languages for locales other than
      # I18n.default_locale. Create the existing ones.
      def check_in_other_langs(key)
        (@languages.keys - [I18n.default_locale]).each do |lang|
          trans = locale(lang).find_by_key(key)
          if trans.nil?
            if value = get_value_from_hash(@languages[lang], key)
              create! :locale => lang, :key => key, :value => value
              Interpret.logger.info "New key created [#{key}] for language [#{lang}]"
            end
          end
        end
      end

      def get_value_from_hash(hash, key)
        key.split(".")[0..-2].each do |k|
          break if hash.nil?
          hash = hash[k]
        end
        hash.nil? ? nil : hash[key.split(".").last]
      end

      def create_new_translation(missing_key, main_value)
        create! :locale => I18n.default_locale, :key => missing_key, :value => main_value
        Interpret.logger.info "New key created [#{missing_key}] for language [#{I18n.default_locale}]"

        check_in_other_langs(missing_key)
      end

      def remove_unused_keys(hash, prefix = "")
        hash.keys.each do |x|
          if hash[x].kind_of?(Hash)
            remove_unused_keys(hash[x], "#{prefix}#{x}.")
          else
            delete_all(:locale => @languages.keys, :key => "#{prefix}#{x}")
            Interpret.logger.info "Removing unused key #{prefix}#{x}"
          end
        end
      end

      def parse_hash(dict, locale, prefix = "")
        res = []
        dict.keys.each do |x|
          if dict[x].kind_of?(Hash)
            res += parse_hash(dict[x], locale, "#{prefix}#{x}.")
          else
            res << new(:locale => locale,
                       :key => "#{prefix}#{x}",
                       :value => dict[x])
          end
        end
        res
      end


    end
  end
end

