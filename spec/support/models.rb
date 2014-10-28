class AdjacencyListTreeItem < Item
  has_hierarchy counter_cache: true,
                path_cache: false,
                order: true
end

class MaterializedPathTreeItem < Item
  has_hierarchy counter_cache: true,
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
