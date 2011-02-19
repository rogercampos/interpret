class Interpret::BaseController < eval(Interpret.parent_controller.classify)
  before_filter :set_locale
  before_filter :interpret_set_current_user
  layout 'interpret'

private
  def set_locale
    I18n.locale = params[:locale] if params[:locale]
  end

  def interpret_set_current_user
    if Interpret.current_user && defined?(Interpret.current_user.to_sym)
      @interpret_user = eval(Interpret.current_user)
      @interpret_admin = true
      if Interpret.admin && @interpret_user.respond_to?(Interpret.admin)
        @interpret_admin = @interpret_user.send(Interpret.admin)
      end
    end
  end
end

