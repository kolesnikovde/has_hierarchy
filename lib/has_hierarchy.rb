require 'active_record'
require 'has_hierarchy/version'
require 'has_hierarchy/order'
require 'has_hierarchy/path'
require 'has_hierarchy/depth_cache'
require 'has_hierarchy/counter_cache'
require 'has_hierarchy/orm_adapter'

module HasHierarchy
  DEFAULT_OPTIONS = {
    scope: nil,
    order: :position,
    path_cache: :path,
    path_part: :id,
    path_separator: '/',
    depth_cache: :depth,
    counter_cache: :children_count,
    dependent: nil
  }

  def has_hierarchy(options = {})
    extend ClassMethods
    include InstanceMethods

    setup_has_hierarchy_options(options)

    include Order        if options[:order]
    include Path         if options[:path_cache]
    include DepthCache   if options[:depth_cache]
    include CounterCache if options[:counter_cache]

    belongs_to :parent, class_name: self.name,
                        inverse_of: :children

    has_many :children, class_name: self.name,
                        foreign_key: :parent_id,
                        inverse_of: :parent,
                        dependent: options[:dependent]

    define_tree_scope(options[:scope])

    include HasHierarchy::OrmAdapter
  end

  module ClassMethods
    def roots
      where(parent_id: nil)
    end

    def tree
      nodes = all
      tree_hash = {}

      index = {}
      nodes.each{ |n| index[n.id] = {} }
      nodes.each{ |n| (index[n.parent_id] || tree_hash)[n] = index[n.id] }

      tree_hash
    end

    def flat_tree(tree_hash = nil)
      tree_hash ||= tree
      list = []

      tree_hash.each do |node, children|
        list << node
        list += flat_tree(children) unless children.empty?
      end

      list
    end

    protected

    def setup_has_hierarchy_options(options)
      options.assert_valid_keys(DEFAULT_OPTIONS.keys)

      # Set to false if nil.
      options.reverse_merge!(depth_cache: false, counter_cache: false)

      DEFAULT_OPTIONS.each do |key, value|
        options[key] = value if options[key].nil? or options[key] == true
      end

      cattr_accessor(:path_column) { options[:path_cache] }
      cattr_accessor(:path_part_column) { options[:path_part] }
      cattr_accessor(:path_separator) { options[:path_separator] }
      cattr_accessor(:depth_column) { options[:depth_cache] }
      cattr_accessor(:children_count_column) { options[:counter_cache] }
      cattr_accessor(:has_hierarchy_options) { options }
    end

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
      children.count == 0
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
  end
end
