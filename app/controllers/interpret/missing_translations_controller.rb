class Interpret::MissingTranslationsController < Interpret::BaseController
  def index
    authorize! :read, :missing_translations
    return if I18n.locale == I18n.default_locale

    case ActiveRecord::Base.connection.adapter_name
    when "Mysql2"
      res = ActiveRecord::Base.connection.execute("select t.id from translations t where t.locale ='#{I18n.default_locale}' and (select count(*) from translations t2 where t2.key = t.key and t2.locale ='#{I18n.locale}') = 0")

    when "SQLite"
      res = ActiveRecord::Base.connection.execute("select t.id from translations t where t.locale ='#{I18n.default_locale}' and (select count(*) from translations t2 where t2.key = t.key and t2.locale ='#{I18n.locale}') = 0")

    else
      raise NotImplementedError, "database adapter not supported"
    end

    ids = res.map{|x| x.first}
    translations = Interpret::Translation.allowed.where(:id => ids).order("translations.key ASC").all
    translations = translations.select{|x| x.value.present?}
    @missing_translations = translations.map{|x| {:ref_value => x.value, :key => x.key, :source => x}}
  end

  def blank
    authorize! :read, :blank_translations
    @blank_translations = Interpret::Translation.allowed.locale(I18n.locale).where(:value => "--- \"\"\n")
    @ref_translations = Interpret::Translation.allowed.locale(I18n.default_locale).where(:key => @blank_translations.map{|x| x.key})

    @blank_translations.map do |x|
      foo = @ref_translations.detect{|y| x.key == y.key}
      [x, foo ? foo.value : nil]
    end
  end

  def unused
    authorize! :read, :unused_translations
    used_keys = Interpret::Translation.allowed.locale(I18n.default_locale).all.map{|x| x.key}
    @unused_translations = Interpret::Translation.allowed.locale(I18n.locale).where("translations.key NOT IN (?)", used_keys)
  end

  def stale
    @stale_translations = Interpret::Translation.allowed.stale.locale(I18n.locale).order("translations.key ASC")
    refs = Interpret::Translation.locale(I18n.default_locale).where(:key => @stale_translations.map{|x| x.key})
    @stale_translations.map!{|x| [x, refs.detect{|y| y.key == x.key}]}
  end
end
