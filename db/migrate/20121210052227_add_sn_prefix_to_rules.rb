class AddSnPrefixToRules < ActiveRecord::Migration
  def change
	add_column :rules, :serial_prefix, :string
  end
end
