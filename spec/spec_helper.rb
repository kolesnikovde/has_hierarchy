require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'sqlite3'
require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Schema.verbose = false

require File.expand_path('../db/schema.rb', __FILE__)
require File.expand_path('../support/models.rb', __FILE__)
require File.expand_path('../support/matchers.rb', __FILE__)

RSpec.configure do |config|
  config.around :each do |example|
    ActiveRecord::Base.transaction do
      example.run

      raise ActiveRecord::Rollback
    end
  end
end
