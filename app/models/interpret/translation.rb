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

