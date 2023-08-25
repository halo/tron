# frozen_string_literal: true

require File.expand_path('lib/tron/version', __dir__)

Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 3.2.0'

  spec.name        = 'tron'
  spec.version     = Tron::VERSION::STRING
  spec.summary     = 'General-purpose method return objects that can be chained.'
  spec.description = "#{spec.summary} Think minimalistic value object monads. " \
                     'Heavily inspired by the `deterministic` gem, but much much more light-weight.'
  spec.authors     = ['halo']
  spec.homepage    = 'https://github.com/halo/tron'

  spec.files         = Dir['{lib}/**/*', 'README*', 'LICENSE.txt'] & `git ls-files -z`.split("\0")
  spec.licenses      = ['MIT']
  spec.require_paths = ['lib']
  spec.metadata['rubygems_mfa_required'] = 'true'
end
