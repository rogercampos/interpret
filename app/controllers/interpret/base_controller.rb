class Interpret::BaseController < eval(Interpret.controller.classify)
  before_filter :set_locale
  layout 'interpret'

private
  def set_locale
    I18n.locale = params[:locale] if params[:locale]
  end
end

