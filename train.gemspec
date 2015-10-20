require File.expand_path('../lib/train/version', __FILE__)

Gem::Specification.new do |spec|

  spec.required_ruby_version = '>= 2.2.3'

  spec.name        = 'train'
  spec.version     = ::Train::VERSION::STRING
  spec.date        = '2015-10-01'
  spec.summary     = ''
  spec.description = ''
  spec.authors     = %w{ halo }
  spec.homepage    = 'https://github.com/halo/train'

  spec.files         = Dir['Rakefile', '{lib}/**/*', 'README*', 'LICENSE.md'] & `git ls-files -z`.split("\0")
  spec.licenses      = %w{ MIT }
  spec.require_paths = %w{ lib }

  spec.add_development_dependency 'hashie'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'rb-fsevent'

end
