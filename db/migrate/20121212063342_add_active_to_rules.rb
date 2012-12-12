class AddActiveToRules < ActiveRecord::Migration
  def change
    add_column :rules, :active, :boolean
  end
end
