module HasHierarchy
  module DepthCache
    extend ActiveSupport::Concern

    included do
      before_save :cache_depth

      cattr_accessor :depth_column do
        column = has_hierarchy_options[:depth_cache]
        column = :depth if column == true
        column
      end
    end

    protected

    def depth
      self[depth_column] || 0
    end

    def cache_depth
      self[depth_column] = root? ? 0 : (parent.depth + 1)
    end
  end
end
