module HasHierarchy
  module DepthCache
    extend ActiveSupport::Concern

    included do
      before_save :cache_depth
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
