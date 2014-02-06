require 'active_record'
require 'has_children/version'
require 'has_children/adjacency_list'
require 'has_children/materialized_path'

module HasChildren
  def has_children options = {}
    include AdjacencyList

    unless options[:node_path_column] == false
      include MaterializedPath
    end

    cattr_accessor :node_path_column do
      :node_path if options[:node_path_column].nil?
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
        where(Hash[Array(tree_scope).map{ |s| [ s, instance[s] ] }])
      end
    else
      scope :tree_scope, ->(instance) { self }
    end
  end
end

ActiveRecord::Base.extend(HasChildren)
