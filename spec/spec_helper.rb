require 'tron'
require 'hashie/mash' if ENV['LOAD_HASHIE'].to_s != ''

RSpec.configure do |config|

  config.raise_errors_for_deprecations!
  config.disable_monkey_patching!
  config.color = true
  config.fail_fast = true

end
