class CreateClassifiers < ActiveRecord::Migration
  def change
    create_table :classifiers do |t|
      t.string  :target_make
      t.string  :target_model
      t.string  :source_make
      t.string  :source_model
      t.string  :serial_prefix
      t.string  :suggested_prefix
      t.integer :min_sn
      t.integer :max_sn     
      t.integer :source_id 
      t.boolean :active

      t.timestamps
    end
  end
end
