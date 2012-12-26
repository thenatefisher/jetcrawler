class CreateFieldPriorities < ActiveRecord::Migration
  def change
    create_table :field_priorities do |t|
      t.string :field
      t.integer :priority
      t.integer :source_id

      t.timestamps
    end
  end
end
