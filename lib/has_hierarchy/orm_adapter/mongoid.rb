module HasHierarchy
  module OrmAdapter
    module Mongoid
      def ancestors
        tree_scope.where(path_part_column.in => path_parts)
      end

      def siblings
        tree_scope.where(:parent_id => parent_id, :id.ne => id)
      end

      def subtree
        tree_scope.or({ id: id }, descendants_conditions)
      end

      def descendants
        tree_scope.where(descendants_conditions)
      end

      protected

      def descendants_conditions
        { path_column => /^#{path_for_children}/ }
      end
    end
  end
end
