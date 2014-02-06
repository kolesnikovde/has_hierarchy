module HasChildren
  module AdjacencyList
    extend ActiveSupport::Concern

    module ClassMethods
      def tree
        nodes = all
        index = {}
        arranged = {}

        nodes.each do |node|
          struct = node.root? ? arranged : (index[node.parent_id] ||= {})
          struct[node] = (index[node.id] ||= {})
        end

        arranged
      end
    end

    def siblings
      tree_scope.where(siblings_conditions)
    end

    def root?
      parent_id.nil?
    end

    def sibling_of? node
      parent_id == node.parent_id and id != node.id
    end

    protected

    def tree_scope
      self.class.tree_scope(self)
    end

    def siblings_conditions
      t = self.class.arel_table

      t[:parent_id].eq(parent_id).and(t[:id].not_eq(id))
    end
  end
end
