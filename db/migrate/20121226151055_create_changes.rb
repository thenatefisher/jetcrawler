class CreateChanges < ActiveRecord::Migration
  def change
    create_table :changes do |t|
      t.integer :source_id
      t.string :field
      t.text :value
      t.integer :conflict_id

      t.timestamps
    end
  end
end
