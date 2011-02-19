puts "Creating users..."
User.delete_all
User.create :id => 1
User.create :id => 2, :admin => true
