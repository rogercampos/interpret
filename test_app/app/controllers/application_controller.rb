class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_current_user
  helper_method :current_user
  before_filter :set_locale

  def current_user
    session[:user_id] ? User.find(session[:user_id]) : User.first
  end

  def set_current_user
    session[:user_id] = User.first
  end

  def toggle_edition_mode
    Interpret.live_edit = !Interpret.live_edit

    redirect_to :back
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(options = {})
    options.merge({:locale => I18n.locale})
  end

end
