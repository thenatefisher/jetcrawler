class AddTargetToChange < ActiveRecord::Migration
  def change
    add_column :changes, :target_id, :integer
  end
end
