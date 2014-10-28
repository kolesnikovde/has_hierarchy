require 'mongoid'
require 'has_hierarchy'

Mongoid.configure do |config|
  config.connect_to('mongoid_has_hierarchy_test')
end

require_relative 'item_model'

RSpec.configure do |config|
  config.after(:each) { Mongoid.purge! }
end
