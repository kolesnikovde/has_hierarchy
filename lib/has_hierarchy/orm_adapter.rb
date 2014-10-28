module HasHierarchy
  # :nocov:
  module OrmAdapter
    if defined?(::ActiveRecord)
      ::ActiveRecord::Base.extend(HasHierarchy)
    end

    if defined?(::Mongoid)
      module ::Mongoid::HasHierarchy
        def self.included(base)
          base.extend(::HasHierarchy)
        end
      end
    end

    def self.included(base)
      base.class_eval do
        if defined?(::ActiveRecord) and self < ::ActiveRecord::Base
          require 'has_hierarchy/orm_adapter/active_record'
          include ActiveRecord
        elsif defined?(::Mongoid) and self < ::Mongoid::Document
          require 'has_hierarchy/orm_adapter/mongoid'
          include Mongoid
        end
      end
    end
  end
  # :nocov:
end
