require 'interpret/engine' if defined? Rails
require 'best_in_place'
require 'will_paginate'

module Interpret
  mattr_accessor :backend
  mattr_accessor :logger

  mattr_accessor :controller
  @@controller = "application"

  mattr_accessor :scope
  @@scope = "interpret"

  mattr_accessor :resource_name
  @@resource_name = "translations"  # default to :translations, be sure to provide a plural name

  # More options:
  # - memoize?
  # - flatten?
  # - logging?
  # - current_user method. If set, current_user will appear in logs, otherwise not.
end

# Gist from: https://gist.github.com/745617
module LazyHash
  class << self
    def lazy_add(hash, key, value, pre = nil)
      skeys = key.split(".")
      f = skeys.shift
      if skeys.empty?
        pre.nil? ? hash.send("[]=", f, value) : pre.send("[]=", f, value)
      else
        pre = pre.nil? ? hash.send("[]", f) : pre.send("[]", f)
        lazy_add(hash, skeys.join("."), value, pre)
      end
    end

    def build_hash
      lazy = lambda { |h,k| h[k] = Hash.new(&lazy) }
      Hash.new(&lazy)
    end
  end
end


ActionView::Base.send(:include, Interpret::InterpretHelpers)
