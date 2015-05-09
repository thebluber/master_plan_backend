ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/mini_test'
require 'simplecov'
SimpleCov.start 'rails'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include FactoryGirl::Syntax::Methods
end

class ActionController::TestCase
  include Devise::TestHelpers
end

#TODO find out why this following module can not be found if it is in the api_test.rb file in
#/test/api/v1/ directory
module APITest
  @@API_ROOT = "/api/v1"

  def self.included(base)
    base.send :include, Rack::Test::Methods
  end

  def path url
    "#{@@API_ROOT}/#{url}"
  end

  def app
    Rails.application
  end

  def log_in email, pw
    post "#{@@API_ROOT}/users/sign_in", { user: { email: email, password: pw } }
  end

  def log_out
    delete "#{@@API_ROOT}/users/sign_out"
  end
end
