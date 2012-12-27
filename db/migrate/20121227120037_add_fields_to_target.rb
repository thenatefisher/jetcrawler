class AddFieldsToTarget < ActiveRecord::Migration
  def change
    add_column :targets, :equipment, :text
    add_column :targets, :location, :string
    add_column :targets, :avionics, :text
    add_column :targets, :inspection, :text
    add_column :targets, :interior, :text
    add_column :targets, :exterior, :text
    add_column :targets, :description, :text
    add_column :targets, :price, :integer
    add_column :targets, :damage, :boolean
    add_column :targets, :seller, :text
  end
end
