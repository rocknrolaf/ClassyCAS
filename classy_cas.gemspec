# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
  
Gem::Specification.new do |s|
  s.name        = "classy_cas"
  s.version     = "0.9"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Andrew O'Brien", "Tim Case", "Nick Browning"]
  s.email       = ["andrew@econify.com"]
  s.homepage    = "https://github.com/Econify/ClassyCAS"
  s.summary     = "A Central Authentication Service server built on Sinatra and Redis"
  s.description = "ClassyCAS provides private, centralized, cross-domain, platform-agnostic centralized authentication than can hook in with modern Ruby authentication systems."
 
  s.required_rubygems_version = ">= 1.3.6"
 
  s.files        = Dir.glob("{config,lib,public,views}/**/*") + %w(README.textile config.ru)
  s.require_path = 'lib'
end