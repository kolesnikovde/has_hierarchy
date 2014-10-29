module HasHierarchy
  module CounterCache
    extend ActiveSupport::Concern

    included do
      after_save :update_children_counter,       if: :parent_id_changed?
      after_destroy :decrement_children_counter, if: :parent_id?
    end

    protected

    def update_children_counter
      if parent_id
        self.class.increment_counter(children_count_column, parent_id)
      end

      if parent_id_was
        self.class.decrement_counter(children_count_column, parent_id_was)
      end
    end

    def decrement_children_counter
      self.class.decrement_counter(children_count_column, parent_id)
    end
  end
end
