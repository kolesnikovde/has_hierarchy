require 'has_hierarchy'

class Item < ActiveRecord::Base
  scope :alphabetic, ->{ order('name asc') }
end

class AdjacencyListTreeItem < Item
  has_hierarchy counter_cache: :children_count,
                path_cache: false,
                order: true
end

class MaterializedPathTreeItem < Item
  has_hierarchy counter_cache: :children_count,
                path_part: :name
end

class CachedDepthTreeItem < Item
  has_hierarchy depth_cache: true
end

class ScopedWithColumnTreeItem < Item
  has_hierarchy scope: :category
end

class ScopedWithLambdaTreeItem < Item
  has_hierarchy scope: ->(item){ where(category: item.category) },
                # parent_id scope cannot be combined with lambda.
                order: false
end
