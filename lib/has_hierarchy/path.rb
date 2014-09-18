module HasHierarchy
  module Path
    extend ActiveSupport::Concern

    included do
      before_create :populate_path
      before_update :rebuild_subtree, if: :need_to_rebuild_subtree?

      cattr_accessor :path_column do
        column = has_hierarchy_options[:path_cache]
        column = :path if column.nil? or column == true
        column
      end

      cattr_accessor :path_separator do
        has_hierarchy_options[:path_separator] || '/'
      end

      cattr_accessor :path_part_column do
        has_hierarchy_options[:path_part] || :id
      end
    end

    module ClassMethods
      def find_by_path(path)
        sep = path_separator
        parts = path.split(sep)
        part = parts.pop
        path = parts.length > 0 ? parts.join(sep) + sep : ''

        where(path_part_column => part, path_column => path).first
      end
    end

    def root
      self.class.find_by(path_part_column => path_parts.first)
    end

    def root_of?(node)
      node.path_parts.first == path_part if path_part.present?
    end

    def ancestors
      tree_scope.where(ancestors_conditions)
    end

    def ancestor_of?(node)
      node.path_parts.include?(path_part)
    end

    def descendants
      tree_scope.where(descendants_conditions)
    end

    def descendant_of?(node)
      path_parts.include?(node.path_part)
    end

    def subtree
      tree_scope.where(subtree_conditions)
    end

    def depth
      path_parts.size
    end

    def path
      self[path_column]
    end

    def path=(path)
      self[path_column] = path
    end

    protected

    def path_part
      self[path_part_column].to_s
    end

    def path_parts
      path.split(path_separator)
    end

    def path_for_children
      [ path, path_part, path_separator ].join
    end

    def populate_path
      self.path = root? ? '' : parent.path_for_children
    end

    def ancestors_conditions
      { path_part_column => path_parts }
    end

    def descendants_conditions
      arel_path = self.class.arel_table[path_column]
      arel_path.matches("#{path_for_children}%")
    end

    def subtree_conditions
      arel_path_part = self.class.arel_table[path_part_column]
      arel_path_part.eq(path_part).or(descendants_conditions)
    end

    def rebuild_subtree
      populate_path

      children.each do |child|
        child.rebuild_subtree
        child.save!
      end
    end

    def need_to_rebuild_subtree?
      parent_id_changed? or changed_attributes.include?(path_part_column)
    end
  end
end
