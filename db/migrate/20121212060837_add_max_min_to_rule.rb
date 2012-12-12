class AddMaxMinToRule < ActiveRecord::Migration
  def change
      add_column :rules, :min_sn, :integer
      add_column :rules, :max_sn, :integer
  end
end
