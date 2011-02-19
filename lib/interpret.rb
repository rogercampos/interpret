require 'best_in_place'
require 'will_paginate'
require 'lazyhash'

module Interpret
  mattr_accessor :backend
  mattr_accessor :logger

  mattr_accessor :controller
  @@controller = "action_controller/base"

  mattr_accessor :sweeper
  @@sweeper = nil

  mattr_accessor :registered_envs
  @@registered_envs = [:production, :staging]

  mattr_accessor :scope
  @@scope = ""

  mattr_accessor :current_user
  @@current_user = nil

  mattr_accessor :admin
  @@admin = nil
end

require 'interpret/engine' if defined? Rails

ActionView::Base.send(:include, Interpret::InterpretHelpers)
