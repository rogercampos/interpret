require 'interpret/engine' if defined? Rails

module Interpret
  mattr_accessor :backend

  mattr_accessor :controller
  @@controller = "interpret/transaltions"
end
