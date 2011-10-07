class Interpret::MissingTranslationsController < Interpret::BaseController
  def index
    unless I18n.locale == I18n.default_locale

      case ActiveRecord::Base.connection.adapter_name
      when "Mysql2"
        res = ActiveRecord::Base.connection.execute("select t.value, t.key from translations t where t.locale ='#{I18n.default_locale}' and (select count(*) from translations t2 where t2.key = t.key and t2.locale ='#{I18n.locale}') = 0")
        @missing_translations = res.map{|x| {:ref_value => YAML.load(x[0]), :key => x[1]}}

      when "SQLite"
        res = ActiveRecord::Base.connection.execute("select t.value, t.key from translations t where t.locale ='#{I18n.default_locale}' and (select count(*) from translations t2 where t2.key = t.key and t2.locale ='#{I18n.locale}') = 0")
        @missing_translations = res.map{|x| {:ref_value => YAML.load(x["value"]), :key => x["key"]}}

      else
        raise NotImplementedError, "database adapter not supported"
      end
    end
  end
end
