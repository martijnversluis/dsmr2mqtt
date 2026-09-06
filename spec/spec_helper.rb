# frozen_string_literal: true

require "dsmr2mqtt"

# Keep the test output clean.
Dsmr2mqtt.logger = Logger.new(File::NULL)

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.disable_monkey_patching!
  config.order = :random
end
