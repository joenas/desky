# -*- encoding: utf-8 -*-
require File.expand_path('../lib/desky/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["jonnev"]
  gem.email         = ["jonnev@bredband2.se"]
  gem.description   = %q{}
  gem.summary       = %q{Supersmart app launcher}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
#  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.executable    = 'desky'
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "desky"
  gem.require_paths = ["lib"]
  gem.version       = Desky::VERSION
  gem.add_runtime_dependency "thor"
end
