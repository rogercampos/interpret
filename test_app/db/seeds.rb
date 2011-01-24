I18n.locale = :en

User.delete_all
puts "Creating users..."
User.create! :login => "admin", :password => "password", :password_confirmation => "password"

