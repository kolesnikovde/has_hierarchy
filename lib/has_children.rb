require 'active_record'
require 'has_children/version'
require 'has_children/adjacency_list'
require 'has_children/order'
require 'has_children/materialized_path'
require 'has_children/depth_cache'

module HasChildren
  # options - Options hash.
  #           :scope               - optional, proc, symbol or an array of symbols.
  #           :position            - optional, column name or boolean, default :position.
  #           :node_path_cache     - optional, column name or boolean, default :node_path.
  #           :node_path_separator - optional, string, default '.'.
  #           :node_id_column      - optional, column name, default :id.
  #           :depth_cache         - optional, column name or boolean, default :depth.
  #           :counter_cache       - optional, :counter_cache option for parent association.
  #           :dependent           - optional, :dependent option for children association.
  def has_children(options = {})
    cattr_accessor :has_children_options do
      options
    end

    include AdjacencyList

    unless options[:position] == false
      include Order
    end

    unless options[:node_path_cache] == false
      include MaterializedPath
    end

    if options[:depth_cache]
      include DepthCache
    end

    belongs_to :parent, class_name: self.name,
                        inverse_of: :children,
                        counter_cache: options[:counter_cache]

    has_many :children, class_name: self.name,
                        foreign_key: :parent_id,
                        inverse_of: :parent,
                        dependent: options[:dependent]

    define_tree_scope(options[:scope])
  end

  protected

  def define_tree_scope(tree_scope)
    scope :tree_scope, case tree_scope
    when Proc
      tree_scope
    when nil
      ->(model) { self }
    else
      ->(model) { where(Hash[Array(tree_scope).map{ |s| [ s, model[s] ] }]) }
    end
  end
end

ActiveRecord::Base.extend(HasChildren)
