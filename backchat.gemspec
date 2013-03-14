# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'backchat/version'

Gem::Specification.new do |spec|
  spec.name          = 'backchat'
  spec.version       = Backchat::VERSION
  spec.authors       = ['Zach Pendleton']
  spec.email         = ['zachpendleton@gmail.com']
  spec.description   = %q{Smack XMPP libraries for JRuby. With connection pooling!!}
  spec.summary       = %q{Include Smack XMPP libraries in JRuby and use them with connection pooling.}
  spec.homepage      = 'https://github.com/zachpendleton/backchat'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler',            '~> 1.3'
  spec.add_development_dependency 'minitest',           '~> 4.6.2'
  spec.add_development_dependency 'minitest-reporters', '~> 0.14.7'
  spec.add_development_dependency 'mocha',              '~> 0.13.3'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake',               '>= 0.9.6'
end
