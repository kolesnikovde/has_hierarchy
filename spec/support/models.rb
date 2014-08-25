require 'has_children'

class Item < ActiveRecord::Base
  scope :alphabetic, ->{ order('name asc') }
end

class AdjacencyListTreeItem < Item
  has_children counter_cache: :children_count,
               node_path_cache: false
end

class MaterializedPathTreeItem < Item
  has_children counter_cache: :children_count,
               node_id_column: :name
end

class ScopedWithColumnTreeItem < Item
  has_children scope: :category
end

class ScopedWithLambdaTreeItem < Item
  has_children scope: ->(item){ where(category: item.category) }
end
