class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_current_user
  helper_method :current_user

  def current_user
    User.find session[:user_id]
  end

  def set_current_user
    # hardcoded users in database from seeds
    if params[:admin]
      session[:user_id] = params[:admin] == "true" ? User.where(:admin => true).first : User.where(:admin => false).first
    end
  end
end
