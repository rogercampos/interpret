require 'best_in_place'
require 'lazyhash'
require 'cancan'

module Interpret
  mattr_accessor :backend
  mattr_accessor :logger
  mattr_accessor :sweeper
  mattr_accessor :parent_controller
  mattr_accessor :registered_envs
  mattr_accessor :current_user
  mattr_accessor :soft
  mattr_accessor :black_list
  mattr_accessor :ability

  @@parent_controller = "application_controller"
  @@registered_envs = [:production, :staging]
  @@soft = true
  @@black_list = []
  @@current_user = "current_user"
  @@ability = "interpret/ability"

  def self.configure
    yield self
  end

  def self.fixed_blacklist
    @@black_list.select{|x| !x.include?("*")}
  end

  def self.wild_blacklist
    @@black_list.select{|x| x.include?("*")}.map{|x| x.gsub("*", "")}
  end

  def self.ability
    unless @@ability.is_a?(Class)
      @@ability.classify.constantize
    else
      @@ability
    end
  end
end

require 'interpret/engine' if defined? Rails
