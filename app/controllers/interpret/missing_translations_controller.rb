class Interpret::MissingTranslationsController < Interpret::BaseController
  def index
    unless I18n.locale == I18n.default_locale

      case ActiveRecord::Base.connection.adapter_name
      when "Mysql2"
        res = ActiveRecord::Base.connection.execute("select t.id from translations t where t.locale ='#{I18n.default_locale}' and (select count(*) from translations t2 where t2.key = t.key and t2.locale ='#{I18n.locale}') = 0")

      when "SQLite"
        res = ActiveRecord::Base.connection.execute("select t.id from translations t where t.locale ='#{I18n.default_locale}' and (select count(*) from translations t2 where t2.key = t.key and t2.locale ='#{I18n.locale}') = 0")

      else
        raise NotImplementedError, "database adapter not supported"
      end

      ids = res.map{|x| x.first}
      translations = Interpret::Translation.where(:id => ids)
      @missing_translations = translations.map{|x| {:ref_value => x.value, :key => x.key}}
    end
  end
end
