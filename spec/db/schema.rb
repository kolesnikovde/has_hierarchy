ActiveRecord::Schema.define(version: 0) do
  create_table :items, force: true do |t|
    t.string :name
    t.string :node_path
    t.integer :position

    t.belongs_to :parent
  end
end
