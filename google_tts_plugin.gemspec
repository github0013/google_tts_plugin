# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "google_tts_plugin/version"

Gem::Specification.new do |s|
  s.name        = "google_tts_plugin"
  s.version     = GoogleTTSPlugin::VERSION
  s.authors     = ["ore"]
  s.email       = ["orenoimac@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{connects adhearsion with google tts}
  s.description = %q{this gem overrides adhearsion#say and use google tts to speak}

  s.rubyforge_project = "google_tts_plugin"

  # Use the following if using Git
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_runtime_dependency %q<adhearsion>, ["~> 2.1"]
  s.add_runtime_dependency %q<activesupport>, [">= 3.0.10"]
  s.add_runtime_dependency %q<mechanize>

  s.add_development_dependency %q<bundler>, ["~> 1.0"]
  s.add_development_dependency %q<rake>, [">= 0"]
  s.add_development_dependency %q<guard-rspec>
  s.add_development_dependency %q<guard-spork>
  s.add_development_dependency %q<webmock>
  if RUBY_PLATFORM =~ /darwin/
    s.add_development_dependency %q<rb-fsevent>, ['~> 0.9.1'] 
    s.add_development_dependency %q<growl>
  end
 end
