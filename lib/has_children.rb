require 'active_record'
require 'has_children/version'
require 'has_children/adjacency_list'
require 'has_children/materialized_path'

module HasChildren
  # options - Options hash.
  #           :scope            - optional, proc, symbol or an array of symbols.
  #           :node_path_cache  - optional, symbol or boolean, default :node_path.
  #           :node_id_column   - optional, symbol, default :id.
  #           :counter_cache    - optional, :counter_cache option for parent association.
  #           :dependent        - optional, :dependent option for children association.
  def has_children(options = {})
    cattr_accessor :has_children_options do
      options
    end

    include AdjacencyList

    unless options[:node_path_cache] == false
      include MaterializedPath
    end

    belongs_to :parent, class_name: self.name,
                        inverse_of: :children,
                        counter_cache: options[:counter_cache]

    has_many :children, class_name: self.name,
                        foreign_key: :parent_id,
                        inverse_of: :parent,
                        dependent: options[:dependent]

    scope :roots, ->{ where(parent_id: nil) }

    define_tree_scope(options[:scope])
  end

  protected

  def define_tree_scope(tree_scope)
    scope :tree_scope, case tree_scope
    when Proc
      tree_scope
    when nil
      ->(model){ self }
    else
      ->(model) { where(Hash[Array(tree_scope).map{ |s| [ s, model[s] ] }]) }
    end
  end
end

ActiveRecord::Base.extend(HasChildren)
