module HasHierarchy
  module Path
    extend ActiveSupport::Concern

    included do
      before_save :rebuild_subtree, if: :need_to_rebuild_subtree?
    end

    module ClassMethods
      def find_by_path(path)
        sep = path_separator
        parts = path.split(sep).reject(&:blank?)
        part = parts.pop
        path = parts.length > 0 ? parts.join(sep) + sep : ''

        where(path_part_column => part, path_column => path).first
      end

      def find_by_path!(path)
        find_by_path(path) or raise ActiveRecord::RecordNotFound
      end
    end

    def root
      if root_part = path_parts.first
        self.class.find_by(path_part_column => root_part)
      end
    end

    def root_of?(node)
      node.path_parts.first == path_part if path_part.present?
    end

    def ancestor_of?(node)
      node.path_parts.include?(path_part)
    end

    def descendant_of?(node)
      path_parts.include?(node.path_part)
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

    def full_path
      path + path_part
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

    def populate_path(path = nil)
    end

    def rebuild_subtree(path = nil)
      self.path = root? ? '' : (path || parent.path_for_children)

      unless new_record?
        children.each do |child|
          child.rebuild_subtree(path_for_children)
          child.save!
        end
      end
    end

    def need_to_rebuild_subtree?
      parent_id_changed? or changed_attributes.include?(path_part_column.to_s)
    end
  end
end
