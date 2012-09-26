p ENV['BUNDLE_GEMFILE']

require "bundler/setup"
Bundler.require(:default, :development)

Mongoid.configure do |config|
  if Mongoid::Slugify.mongoid3?
    config.sessions[:default] = { :database => 'mongoid_slugify_test', :hosts => ['localhost:27017'] }
  else
    config.master = Mongo::Connection.new.db('mongoid_slugify_test')
  end
end

DatabaseCleaner.strategy = :truncation
DatabaseCleaner.orm = Mongoid::Slugify.mongoid3? ? :moped : :mongoid

RSpec.configure do |config|
  config.before :each do
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end
end
