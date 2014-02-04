if ENV['SIMPLECOV']
  require 'simplecov'
  SimpleCov.start 'rails'
end

require 'fileutils'
require 'logger'
require 'sqlite3'
require 'active_record'

FileUtils.mkdir_p('tmp/logs/')
ActiveRecord::Base.logger = Logger.new('tmp/logs/test.log')
ActiveRecord::Base.logger.level = Logger::DEBUG
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Schema.verbose = false

require File.expand_path('../db/schema.rb', __FILE__)
require File.expand_path('../support/models.rb', __FILE__)

RSpec.configure do |config|
  config.around :each do |example|
    ActiveRecord::Base.transaction do
      example.run

      raise ActiveRecord::Rollback
    end
  end
end
