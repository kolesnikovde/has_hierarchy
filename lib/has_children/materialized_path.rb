module HasChildren
  module MaterializedPath
    extend ActiveSupport::Concern

    included do
      belongs_to :root, class_name: self.name

      before_create :populate_node_path
      before_update :apply_parent_change_to_children, if: :parent_id_changed?
    end

    def depth
      ancestor_ids.size
    end

    # Overriden in order to resolve columnless root association,
    # see ActiveRecord::Associations::BelongsToAssociation#foreign_key_present?
    def [](key)
      key.to_sym == :root_id ? root_id : super
    end

    def root_id
      root? ? nil : ancestor_ids.first
    end

    def root_of?(node)
      node.root_id == id if id.present?
    end

    def ancestor_ids
      node_path.split('.').map(&:to_i)
    end

    def ancestors
      tree_scope.where(ancestors_conditions)
    end

    def ancestor_of?(node)
      node.ancestor_ids.include?(id)
    end

    def descendants
      tree_scope.where(descendants_conditions)
    end

    def descendant_of?(node)
      ancestor_ids.include?(node.id)
    end

    def subtree
      tree_scope.where(subtree_conditions)
    end

    protected

    def node_path
      self[node_path_column]
    end

    def node_path=(path)
      self[node_path_column] = path
    end

    def path_for_children_nodes
      [ node_path, id, '.' ].join
    end

    def populate_node_path
      self.node_path = root? ? '' : parent.path_for_children_nodes
    end

    def ancestors_conditions
      { id: ancestor_ids }
    end

    def descendants_conditions(path = nil)
      path ||= path_for_children_nodes

      self.class.arel_table[node_path_column].matches("#{path}%")
    end

    def subtree_conditions
      self.class.arel_table[:id].eq(id).or(descendants_conditions)
    end

    def apply_parent_change_to_children
      old_path = path_for_children_nodes
      populate_node_path
      new_path = path_for_children_nodes
      column = node_path_column

      set = "#{column} = replace(#{column}, '#{old_path}', '#{new_path}')"
      tree_scope.where(descendants_conditions(old_path)).update_all(set)
    end
  end
end
