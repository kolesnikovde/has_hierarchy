require 'active_record'
require 'has_order/version'

module HasOrder
  def has_order options = {}
    extend  ClassMethods
    include InstanceMethods

    cattr_accessor :position_column do
      options[:position_column] || :position
    end

    cattr_accessor :position_shift_interval do
      options[:shift_interval] || 1000
    end

    before_save :set_default_position, if: :set_default_position?

    define_list_scope(options[:scope])
  end

  module ClassMethods
    def at pos
      where(position_column => pos)
    end

    def ordered
      order(arel_table[position_column].asc)
    end

    def shift!
      col = position_column
      update_all("#{col} = #{col} + #{position_shift_interval}")
    end

    def next_position
      maximum(position_column).to_i + position_shift_interval
    end
  end

  module InstanceMethods
    def position
      self[position_column]
    end

    def position= pos
      self[position_column] = pos
    end

    def lower
      where_position(:lt)
    end

    def and_lower
      where_position(:lteq)
    end

    def higher
      where_position(:gt)
    end

    def and_higher
      where_position(:gteq)
    end

    def prev
      lower.ordered.last
    end

    def next
      higher.ordered.first
    end

    def move_to pos
      ActiveRecord::Base.transaction do
        if node = list_scope.at(pos).first
          node.and_higher.shift!
        end

        self.position = pos
        save!
      end
    end

    def move_before node
      node_pos = node.position
      pos = node_pos > 0 ? node_pos - 1 : node_pos

      ActiveRecord::Base.transaction do
        if list_scope.at(pos).exists?
          pos = node_pos
          node.and_higher.shift!
        end

        self.position = pos
        save!
      end
    end

    def move_after node
      node_pos = node.position
      pos = node_pos + 1

      ActiveRecord::Base.transaction do
        if list_scope.at(pos).exists?
          node.higher.shift!
        end

        self.position = pos
        save!
      end
    end

    protected

    def list_scope
      self.class.list_scope(self)
    end

    def where_position cmp
      col = self.class.arel_table[position_column]
      list_scope.where(col.send(cmp, position))
    end

    def set_default_position
      self.position = list_scope.next_position
    end

    def set_default_position?
      position.nil?
    end
  end

  protected

  def define_list_scope list_scope
    scope :list_scope, case list_scope
    when Proc
      list_scope
    when nil
      ->(model) { self }
    else
      ->(model) { where(Hash[Array(list_scope).map{ |s| [ s, model[s] ] }]) }
    end
  end
end

ActiveRecord::Base.extend(HasOrder)
