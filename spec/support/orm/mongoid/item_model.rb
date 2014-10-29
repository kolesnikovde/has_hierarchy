class Item
  include Mongoid::Document
  include Mongoid::HasHierarchy

  field :name,     type: String
  field :path,     type: String
  field :depth,    type: Fixnum, default: 0
  field :category, type: String
  field :children_count, type: Fixnum, default: 0

  scope :alphabetic, ->{ asc(:name) }
end
