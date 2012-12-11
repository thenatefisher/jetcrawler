class AddSnIteratorToAirframes < ActiveRecord::Migration
  def change
	add_column :airframes, :serial_iterator, :integer
  end
end
