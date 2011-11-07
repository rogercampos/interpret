# Avoids using the database_cleaner gem and allow us to have faster
# integration specs with selenium. See https://github.com/jnicklas/capybara at
# transactional fixtures section.


class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || retrieve_connection
  end
end

# Forces all threads to share the same connection. This works on
# Capybara because it starts the web server in a thread.
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection


