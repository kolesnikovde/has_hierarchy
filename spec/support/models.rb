require 'has_children'

class Item < ActiveRecord::Base
  has_children counter_cache: :children_count,
               node_id_column: :name

  scope :alphabetic, ->{ order('name asc') }
end
