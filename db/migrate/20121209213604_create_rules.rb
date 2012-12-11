class CreateRules < ActiveRecord::Migration
  def change
    create_table :rules do |t|
      t.string :jd_make
      t.string :jd_model
      t.string :ex_make
      t.string :ex_model
      t.integer :source_id 

      t.timestamps
    end
  end
end
