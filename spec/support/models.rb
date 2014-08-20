require 'has_children'

class Item < ActiveRecord::Base
  has_children counter_cache: :children_count

  scope :alphabetic, ->{ order('name asc') }
end
