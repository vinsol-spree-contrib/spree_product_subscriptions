# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_product_subscriptions'
  s.version     = '3.2.0'
  s.summary     = 'Add gem summary here'
  s.description = 'Add (optional) gem description here'
  s.required_ruby_version = '>= 2.1.0'

  s.author    = 'Vinay'
  s.email     = 'vinay@vinsol.com'
  # s.homepage  = 'http://www.spreecommerce.com'

  #s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '>= 3.2.0'

  s.add_development_dependency 'capybara', '~> 2.4'
  s.add_development_dependency 'coffee-rails', '~> 4.2'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_bot'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'pry-rails', '~> 0.3.4'
  s.add_development_dependency 'rspec-rails',  '~> 3.4'
  s.add_development_dependency 'rspec-activemodel-mocks', '~> 1.0.3'
  s.add_development_dependency 'sass-rails', '~> 5.0.1'
  s.add_development_dependency 'selenium-webdriver', '~> 2.52.0'
  s.add_development_dependency 'shoulda-matchers', '~> 3.1.1'
  s.add_development_dependency 'shoulda-callback-matchers', '~> 1.1.3'
  s.add_development_dependency 'simplecov', '~> 0.11.2'
  s.add_development_dependency 'sqlite3', '~> 1.3.11'
  s.add_development_dependency 'appraisal'
end
