class Interpret::BaseController < eval(Interpret.parent_controller.classify)
  before_filter :set_locale
  before_filter { authorize! :use, :interpret }
  before_filter :check_authorized_language
  layout 'interpret/interpret'

protected
  def current_interpret_user
    @current_interpret_user ||= eval(Interpret.current_user)
  end

  def current_ability
    @current_ability ||= Interpret.ability.new(current_interpret_user)
  end

private
  def set_locale
    I18n.locale = params[:locale] if params[:locale]
  end

  def check_authorized_language
    authorize! :use, :"interpret_in_#{I18n.locale}"
  end
end

