ActiveRecord::Schema.define(version: 0) do
  create_table :items, force: true do |t|
    t.string :name
    t.string :category
    t.string :path
    t.integer :children_count, default: 0
    t.integer :depth
    t.integer :position

    t.belongs_to :parent
  end
end

class Item < ActiveRecord::Base
  scope :alphabetic, ->{ order('name asc') }
end
