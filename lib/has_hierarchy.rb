require 'active_record'
require 'has_hierarchy/version'
require 'has_hierarchy/order'
require 'has_hierarchy/path'
require 'has_hierarchy/depth_cache'

module HasHierarchy
  def has_hierarchy(options = {})
    cattr_accessor(:has_hierarchy_options) { options }

    extend ClassMethods
    include InstanceMethods

    include Order      unless options[:order] == false
    include Path       unless options[:path_cache] == false
    include DepthCache if options[:depth_cache]

    belongs_to :parent, class_name: self.name,
                        inverse_of: :children,
                        counter_cache: options[:counter_cache]

    has_many :children, class_name: self.name,
                        foreign_key: :parent_id,
                        inverse_of: :parent,
                        dependent: options[:dependent]

    define_tree_scope(options[:scope])
  end

  module ClassMethods
    def roots
      where(parent_id: nil)
    end

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

    protected

    def define_tree_scope(tree_scope)
      scope :tree_scope, case tree_scope
      when Proc
        tree_scope
      when nil
        ->(model) { where(nil) }
      else
        ->(model) { where(Hash[Array(tree_scope).map{ |s| [ s, model[s] ] }]) }
      end
    end
  end

  module InstanceMethods
    def leaf?
      if counter_cache = has_hierarchy_options[:counter_cache]
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

ActiveRecord::Base.extend(HasHierarchy)
