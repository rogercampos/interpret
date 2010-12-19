# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "interpret/version"

Gem::Specification.new do |s|
  s.name        = "interpret"
  s.version     = Interpret::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Roger Campos"]
  s.email       = ["roger@itnig.net"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "interpret"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "rails", "~> 3.0.3"
  s.add_dependency "i18n", "~> 0.5.0"
  s.add_dependency "i18n-active_record"
  s.add_dependency "ya2yaml", ">= 0.30.0"
end
