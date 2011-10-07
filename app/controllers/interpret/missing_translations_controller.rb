class Interpret::MissingTranslationsController < Interpret::BaseController
  def index
    unless I18n.locale == I18n.default_locale
      res = ActiveRecord::Base.connection.execute("select t.value, t.key from
                                                  translations t where
                                                  t.locale ='#{I18n.default_locale}'
                                                  and (select count(*) from
                                                       translations t2 where
                                                       t2.key = t.key and
                                                       t2.locale ='#{I18n.locale}') =
                                                         0")
      @missing_translations = res.map{|x| {:ref_value => YAML.load(x["value"]), :key => x["key"]}}
    end
  end
end
