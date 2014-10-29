require 'active_record'
require 'sqlite3'
require 'has_hierarchy'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Schema.verbose = false

require_relative 'item_model'

RSpec.configure do |config|
  config.around :each do |example|
    ActiveRecord::Base.transaction do
      example.run

      raise ActiveRecord::Rollback
    end
  end
end
