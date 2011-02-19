class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_current_user
  helper_method :current_user

  def current_user
    session[:user_id] ? User.find(session[:user_id]) : User.first
  end

  def set_current_user
    if params[:admin]
      session[:user_id] = params[:admin] == "true" ? User.where(:admin => true).first : User.where(:admin => false).first
    end
  end
end
