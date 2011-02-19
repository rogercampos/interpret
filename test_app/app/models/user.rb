class User < ActiveRecord::Base
  def admin?
    admin
  end
end
