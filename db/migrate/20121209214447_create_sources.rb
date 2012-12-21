class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.string :name
      t.string :label
      t.datetime :latest

      t.timestamps
    end
  end
end
