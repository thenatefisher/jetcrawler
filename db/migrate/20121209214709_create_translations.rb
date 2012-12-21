class CreateTranslations < ActiveRecord::Migration
  def change
    create_table :translations do |t|
      t.integer :target_id
      t.string :token
      t.integer :source_id

      t.timestamps
    end
  end
end
