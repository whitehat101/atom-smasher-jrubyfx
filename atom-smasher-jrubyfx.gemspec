# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'atom-smasher-jrubyfx/version'

Gem::Specification.new do |gem|
  gem.name          = "atom-smasher-jrubyfx"
  gem.version       = AtomSmasherjRubyFX::VERSION
  gem.authors       = ["Jeremy Ebler"]
  gem.email         = ["jebler@gmail.com"]
  gem.description   = %q{AtomSmasher from https://github.com/carldea/JFXGen in jrubyfx}
  gem.summary       = %q{secret}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'engine-jrubyfx', '~> 0.1.0'
end
