# frozen_string_literal: true

require 'tron'

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.raise_errors_for_deprecations!
  config.color = true
  config.order = :random if ENV['CI']
  config.fail_fast = true
end
