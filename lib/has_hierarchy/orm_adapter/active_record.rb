module HasHierarchy
  module OrmAdapter
    module ActiveRecord
      def ancestors
        tree_scope.where(path_part_column => path_parts)
      end

      def siblings
        t = self.class.arel_table

        tree_scope.where(t[:parent_id].eq(parent_id).and(t[:id].not_eq(id)))
      end

      def subtree
        t = self.class.arel_table

        tree_scope.where(t[:id].eq(id).or(descendants_conditions))
      end

      def descendants
        tree_scope.where(descendants_conditions)
      end

      protected

      def descendants_conditions
        t = self.class.arel_table

        t[path_column].matches("#{path_for_children}%")
      end
    end
  end
end

