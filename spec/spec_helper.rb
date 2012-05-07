require "bundler/setup"
Bundler.require(:default, :development)

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db("mongoid_slugify_test")
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
