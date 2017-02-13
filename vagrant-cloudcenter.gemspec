require File.expand_path("../lib/vagrant-cloudcenter/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "vagrant-cloudcenter"
  s.version     = "0.1.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Conor Murphy"]
  s.email       = ["conmurph@cisco.com"]
  #s.homepage    = "NA"
  s.summary     =  "A vagrant provider plugin for Cisco Cloud Center"
  s.description = "NA"

  # If you have other dependencies, add them here
  # s.add_dependency "another", "~> 1.2"

  # If you need to check in files that aren't .rb files, add them here
  s.files        = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md","{locales}/*.yml","../{locales}/*.yml","locales/*.yml"]
  s.require_path = 'lib'

  s.add_runtime_dependency 'highline'
  s.add_runtime_dependency 'colorize'
  s.add_runtime_dependency 'rest-client'
  s.add_runtime_dependency 'json'
  s.add_runtime_dependency 'text-table'

  # If you need an executable, add it here
  # s.executables = ["newgem"]

  # If you have C extensions, uncomment this line
  # s.extensions = "ext/extconf.rb"
end