# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'minesweeper/version'

Gem::Specification.new do |spec|
  spec.name          = "minesweeper"
  spec.version       = Minesweeper::VERSION
  spec.authors       = ["Michael Alexander"]
  spec.email         = ["alexandermw@gmail.com"]
  spec.summary       = %q{Minesweeper on the command line in Ruby, TDD-ed.}
  spec.description   = %q{Tests in Rspec}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"  
  spec.add_development_dependency "rspec", "~> 3.1.0"
  spec.add_development_dependency "guard", "~> 4.5.0"
end
