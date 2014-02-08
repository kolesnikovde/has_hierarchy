require 'active_record'
require 'has_order'
require 'has_children'
require 'has_hierarchy/version'

module HasHierarchy
  def has_hierarchy options = {}
    has_order options.merge(scope: :parent_id)
    has_children options

    after_save :reset_parent_acceptance

    include InstanceMethods
  end

  module InstanceMethods
    def move_before node
      accept_parent(node)
      super
    end

    def move_after node
      accept_parent(node)
      super
    end

    protected

    def accept_parent node
      self.parent_id = node.parent_id
      @parent_accepted = true
    end

    def reset_parent_acceptance
      @parent_accepted = false
    end

    def set_default_position?
      super or parent_id_changed? and not @parent_accepted
    end
  end
end

ActiveRecord::Base.extend(HasHierarchy)
