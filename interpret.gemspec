# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "interpret/version"

Gem::Specification.new do |s|
  s.name        = "interpret"
  s.version     = Interpret::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Roger Campos"]
  s.email       = ["roger@itnig.net"]
  s.homepage    = "https://github.com/rogercampos/interpret"
  s.summary     = %q{Manage your app translations with an i18n active_record backend}
  s.description = %q{Manage your app translations with an i18n active_record backend}

  s.rubyforge_project = "interpret"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "rails", "~> 3.0.3"
  s.add_dependency "i18n", "~> 0.5.0"
  s.add_dependency "i18n-active_record"
  s.add_dependency "ya2yaml", ">= 0.30.0"
  s.add_dependency "will_paginate", ">= 3.0.pre2"
  s.add_dependency "best_in_place", ">= 0.1.7"
end
