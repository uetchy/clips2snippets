# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'clips2snippets/version'

Gem::Specification.new do |spec|
  spec.name          = "clips2snippets"
  spec.version       = Clips2snippets::VERSION
  spec.authors       = ["o_ame"]
  spec.email         = ["oame@oameya.com"]
  spec.description   = %q{Tools that convert Coda Clips to Sublime Text Snippets.}
  spec.summary       = %q{Tools that convert Coda Clips to Sublime Text Snippets.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_dependency "plist"
  spec.add_dependency 'thor'
end
