# Patch to avoid undesired warnings
# https://github.com/jnicklas/capybara/issues/87
# TODO: REMOVE THIS WHEN USING RAILS 3.1
module Rack
  module Utils
    def escape(s)
      CGI.escape(s.to_s)
    end
    def unescape(s)
      CGI.unescape(s)
    end
  end
end
