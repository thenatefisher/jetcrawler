class AddSuggestedPrefixToRules < ActiveRecord::Migration
  def change
	add_column :rules, :suggested_prefix, :string
  end
end
