require 'codeclimate-test-reporter'
# require 'simplecov'

# SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
# SimpleCov::Formatter::HTMLFormatter,
# CodeClimate::TestReporter::Formatter
# ]

# SimpleCov.start 'rails'
CodeClimate::TestReporter.start

ENV['RAILS_ENV'] = 'test'

require File.expand_path('dummy/config/environment', __dir__)
require 'rails/test_help'
require 'minitest/rails'
require 'active_controller_test_response_monkey_patch'

# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
# require "minitest/rails/capybara"

# Uncomment for awesome colorful output
require 'minitest/pride'

ActiveSupport::TestCase.fixture_path = File.expand_path('fixtures', __dir__)
ActionDispatch::IntegrationTest.fixture_path = File.expand_path('fixtures', __dir__)

# I hate the default reporter. Use ProgressReporter instead.
Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def age_token(user, client_id)
    user.tokens[client_id][:updated_at] = Time.zone.now - (DeviseTokenAuth.batch_request_buffer_throttle + 10.seconds)
    user.save!
  end

  def expire_token(user, client_id)
    # byebug
    user.tokens[client_id][:expiry] = (Time.zone.now - (DeviseTokenAuth.token_lifespan.to_f + 10.seconds)).to_i
    user.save!
  end
end

class ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @routes = Dummy::Application.routes
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end
end
