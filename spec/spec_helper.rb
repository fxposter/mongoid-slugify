require "bundler/setup"
Bundler.require(:default, :development)

Mongoid.configure do |config|
  name = "mongoid_slugify_test"
  config.master = Mongo::Connection.new.db(name)
end

DatabaseCleaner.strategy = :truncation
DatabaseCleaner.orm = :mongoid

RSpec.configure do |config|
  config.before :each do
    DatabaseCleaner.start
  end
  
  config.after :each do
    DatabaseCleaner.clean
  end
end
