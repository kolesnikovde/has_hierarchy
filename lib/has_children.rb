require 'active_record'
require 'has_children/version'

module HasChildren
  def has_children options = {}
    extend  TreeMethods
    include AdjacencyListNodeMethods

    unless options[:node_path_column] == false
      include MaterializedPathNodeMethods

      cattr_accessor :node_path_column do
        options[:node_path_column] || :node_path
      end

      before_create :populate_node_path
      before_update :apply_parent_change_to_children, if: :parent_id_changed?
    end

    belongs_to :parent, class_name: self.name,
                        inverse_of: :children,
                        counter_cache: (options[:counter_cache] || false)

    has_many :children, class_name: self.name,
                        foreign_key: :parent_id,
                        inverse_of: :parent,
                        dependent: (options[:orphan_strategy] || :destroy)

    scope :roots, ->{ where(parent_id: nil) }

    if tree_scope = options[:scope]
      scope :tree_scope, ->(instance) do
        where(Hash[Array(tree_scope).map { |s| [ s, instance[s] ] }])
      end
    else
      scope :tree_scope, ->(instance) { self }
    end
  end

  module TreeMethods
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

  module AdjacencyListNodeMethods
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

  module MaterializedPathNodeMethods
    def depth
      ancestor_tokens.size
    end

    def root
      root? ? self : tree_scope.find(ancestor_tokens.first)
    end

    def ancestor_tokens
      node_path.split('.').map(&:to_i)
    end

    def ancestors
      tree_scope.where(ancestors_conditions)
    end

    def descendants
      tree_scope.where(descendants_conditions)
    end

    def subtree
      tree_scope.where(subtree_conditions)
    end

    def ancestor_of? node
      node.ancestor_tokens.include?(id)
    end

    def descendant_of? node
      ancestor_tokens.include?(node.id)
    end

    protected

    def node_path
      self[node_path_column]
    end

    def node_path= path
      self[node_path_column] = path
    end

    def path_for_children_nodes
      [ node_path, id, '.' ].join
    end

    def populate_node_path
      self.node_path = root? ? '' : parent.path_for_children_nodes
    end

    def ancestors_conditions
      { id: ancestor_tokens }
    end

    def descendants_conditions path = nil
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

ActiveRecord::Base.extend(HasChildren)
