require 'has_order'

module HasHierarchy
  module Order
    extend ActiveSupport::Concern

    included do
      include Mongoid::HasOrder if defined?(Mongoid)

      options = has_hierarchy_options

      has_order scope: Array(options[:scope]).concat([ :parent_id ]),
                position_column: options[:order]

      include HasOrderOverrides
    end

    module HasOrderOverrides
      def move_before(node)
        self.parent_id = node.parent_id
        @prevent_default_position = true
        super
        @prevent_default_position = false
      end

      def move_after(node)
        self.parent_id = node.parent_id
        @prevent_default_position = true
        super
        @prevent_default_position = false
      end

      protected

      def set_default_position?
        super or (parent_id_changed? and not @prevent_default_position)
      end
    end
  end
end
