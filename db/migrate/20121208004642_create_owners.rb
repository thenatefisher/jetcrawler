class CreateOwners < ActiveRecord::Migration
  def change
    create_table :owners do |t|
      t.string :name
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state
      t.string :postal
      t.string :country
      t.integer :airframe_id
      t.datetime :start
      t.datetime :end
      t.integer :source_id

      t.timestamps
    end
  end
end
