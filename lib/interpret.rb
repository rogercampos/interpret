require 'interpret/engine' if defined? Rails
require 'best_in_place'
require 'will_paginate'
require 'interpret/lazy_hash'

module Interpret
  mattr_accessor :backend
  mattr_accessor :logger

  mattr_accessor :controller
  @@controller = "application"

  # More options:
  # - memoize?
  # - flatten?
  # - logging?
  # - current_user method. If set, current_user will appear in logs, otherwise not.
end


ActionView::Base.send(:include, Interpret::InterpretHelpers)
