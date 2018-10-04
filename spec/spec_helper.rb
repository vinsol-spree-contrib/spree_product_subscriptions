require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
  add_group  'Controllers', 'app/controllers'
  add_group  'Models', 'app/models'
  add_group  'Overrides', 'app/overrides'
  add_group  'Libraries', 'lib'
end

ENV['RAILS_ENV'] ||= 'test'

begin
  require File.expand_path('../dummy/config/environment', __FILE__)
rescue LoadError
  puts 'Could not load dummy application. Please ensure you have run `bundle exec rake test_app`'
  exit
end

require 'rspec/rails'
require 'database_cleaner'
require 'ffaker'
require 'shoulda-matchers'
require 'shoulda-callback-matchers'
require 'pry'
require "spree/testing_support/factories"
require 'spree/testing_support/url_helpers'
require "spree/testing_support/authorization_helpers"
require "spree/testing_support/controller_requests"
require 'spree/testing_support/preferences'
require 'rspec/active_model/mocks'

RSpec.configure do |config|
  config.include(Shoulda::Matchers::ActiveModel, type: :model)
  config.include(Shoulda::Matchers::ActiveRecord, type: :model)
  config.mock_with :rspec
  config.use_transactional_fixtures = false
  config.fail_fast = false
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.infer_spec_type_from_file_location!
  config.raise_errors_for_deprecations!
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.before :suite do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end

  # Before each spec check if it is a Javascript test and switch between using database transactions or not where necessary.
  config.before :each do
    DatabaseCleaner.strategy = RSpec.current_example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
  end

  # After each spec clean the database.
  config.after :each do
    DatabaseCleaner.clean
  end
  config.include Spree::TestingSupport::ControllerRequests, type: :controller
  config.include Spree::TestingSupport::UrlHelpers
  config.include Devise::TestHelpers, type: :controller

end


 ActiveJob::Base.queue_adapter = :test



Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |file| require file }
