require "bundler/setup"
Bundler.require(:default, :development)

if Gem::Version.new(Mongoid::VERSION) < Gem::Version.new('3.0.0')
  Mongoid.configure do |config|
    config.master = Mongo::Connection.new.db('mongoid_slugify_test')
  end
elsif Gem::Version.new(Mongoid::VERSION) < Gem::Version.new('5.0.0')
  Mongoid.configure do |config|
    config.sessions[:default] = HashWithIndifferentAccess.new({ :database => 'mongoid_slugify_test', :hosts => ['localhost:27017'] })
  end
else
  Mongoid.configure do |config|
    config.clients.default = { :hosts => ['localhost:27017'], database: 'my_db' }
  end
  Mongo::Logger.logger.level = Logger::INFO
end

DatabaseCleaner[:mongoid, { :connection => 'mongoid_slugify_test' }].strategy = :truncation

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :should }

  config.before :each do
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end
end
