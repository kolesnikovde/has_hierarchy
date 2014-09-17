module HasChildren
  module MaterializedPath
    extend ActiveSupport::Concern

    included do
      before_create :populate_node_path
      before_update :rebuild_subtree, if: :need_to_rebuild_subtree?

      cattr_accessor :node_path_column do
        column = has_children_options[:node_path_cache]
        column = :node_path if column.nil? or column == true
        column
      end

      cattr_accessor :node_path_separator do
        has_children_options[:node_path_separator] || '.'
      end

      cattr_accessor :node_id_column do
        has_children_options[:node_id_column] || :id
      end
    end

    module ClassMethods
      def find_by_node_path(path)
        sep = node_path_separator
        parts = path.split(sep)
        id = parts.pop
        path = parts.length > 0 ? parts.join(sep) + sep : ''

        where(node_id_column => id, node_path_column => path).first
      end
    end

    def root
      self.class.find_by(node_id_column => root_id)
    end

    def root_of?(node)
      node.root_id == node_id if node_id.present?
    end

    def ancestors
      tree_scope.where(ancestors_conditions)
    end

    def ancestor_of?(node)
      node.ancestor_ids.include?(node_id)
    end

    def descendants
      tree_scope.where(descendants_conditions)
    end

    def descendant_of?(node)
      ancestor_ids.include?(node.node_id)
    end

    def subtree
      tree_scope.where(subtree_conditions)
    end

    def depth
      ancestor_ids.size
    end

    protected

    def node_id
      self[node_id_column].to_s
    end

    def node_path
      self[node_path_column]
    end

    def node_path=(path)
      self[node_path_column] = path
    end

    def root_id
      root? ? nil : ancestor_ids.first
    end

    def ancestor_ids
      node_path.split(node_path_separator)
    end

    def path_for_children
      [ node_path, node_id, node_path_separator ].join
    end

    def populate_node_path
      self.node_path = root? ? '' : parent.path_for_children
    end

    def ancestors_conditions
      { node_id_column => ancestor_ids }
    end

    def descendants_conditions
      arel_node_path = self.class.arel_table[node_path_column]
      arel_node_path.matches("#{path_for_children}%")
    end

    def subtree_conditions
      arel_node_id = self.class.arel_table[node_id_column]
      arel_node_id.eq(node_id).or(descendants_conditions)
    end

    def rebuild_subtree
      populate_node_path

      children.each do |child|
        child.rebuild_subtree
        child.save!
      end
    end

    def need_to_rebuild_subtree?
      parent_id_changed? or changed_attributes.include?(node_id_column)
    end
  end
end
