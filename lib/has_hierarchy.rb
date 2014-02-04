require 'active_record'
require 'has_order'
require 'has_children'
require 'has_hierarchy/version'

module HasHierarchy
  def has_hierarchy options = {}
    has_order options.merge(scope: :parent_id)
    has_children options

    include InstanceMethods
  end

  module InstanceMethods
    def move_before node
      self.parent_id = node.parent_id

      super
    end

    def move_after node
      self.parent_id = node.parent_id

      super
    end
  end
end

ActiveRecord::Base.extend(HasHierarchy)
