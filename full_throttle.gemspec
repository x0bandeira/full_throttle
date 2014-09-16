# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'throttle/version'

Gem::Specification.new do |spec|
  spec.name          = "full_throttle"
  spec.version       = Throttle::VERSION
  spec.authors       = ["Rafael Bandeira"]
  spec.email         = ["rafaelbandeira3@gmail.com"]
  spec.summary       = %q{Throttle mechanism for distributed work}
  spec.description   = %q{Redis based throttle mechanism to be used by concurrent background jobs}
  spec.homepage      = "https://github.com/rafaelbandeira3/full_throttle"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "redis", "~> 3.0"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 2.3"
  spec.add_development_dependency "timecop", "~> 0.7.1"
end
