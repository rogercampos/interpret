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
      def get_tree(lang = I18n.locale)
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
        {"index" => eval(tree.to_s)}
      end

      # Generate a hash from the given translations. That hash can be
      # ya2yaml'ized to get a standard .yml locale file.
      def export(translations)
        res = LazyHash.build_hash

        translations.each do |e|
          LazyHash.lazy_add(res, "#{e.locale}.#{e.key}", e.value)
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
        to_remove = locale(lang).all
        to_remove.each do |x|
          x.destroy
        end
        records = parse_hash(hash.first[1], lang)
        # TODO: Replace with activerecord-import bulk inserts
        transaction do
          records.each {|x| x.save!}
        end
      end

      # Dump all contents from *.yml locale files into the database.
      # CAUTION: All existing data will be erased!
      #
      # It will create a "#{locale}.yml.backup" file into config/locales
      # for each language present in the database, in case you want to
      # recover some of your just-erased translations.
      # If you don't want backups, set:
      #
      # Interpret.options[:dump_without_backup] = true
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
      #   - If a key is present in the db, but not in the new ones, remove
      #   it. You have removed it from the new content layout, so it's no longer
      #   needed.
      #   - If the key is not present in the db, it's new. So, create a new
      #   entry for that key in each language. Look if a translation for that
      #   key exists in yml files for each language, if it exists, use it. If
      #   not, left it empty.
      #   - If the key already exists in the db, do nothing. Maybe somone has
      #   changed that content in production, and you don't want to lose
      #   that. Or maybe you do want to change that content, because you
      #   just added the correct sentence in the yml files. It's up to you to
      #   do the right thing.
      def update

      end

    private
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

