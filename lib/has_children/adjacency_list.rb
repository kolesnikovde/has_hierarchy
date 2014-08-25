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

    def leaf?
      if counter_cache = has_children_options[:counter_cache]
        self[counter_cache] == 0
      else
        children.empty?
      end
    end

    def root?
      parent_id.nil?
    end

    def parent_of?(node)
      node.parent_id == id
    end

    def child_of?(node)
      node.id == parent_id
    end

    def sibling_of?(node)
      parent_id == node.parent_id and id != node.id
    end

    def siblings
      tree_scope.where(siblings_conditions)
    end

    def move_children_to_parent
      children.each do |c|
        c.parent = self.parent
        c.save
      end
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
