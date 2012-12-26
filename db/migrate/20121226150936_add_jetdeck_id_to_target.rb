class AddJetdeckIdToTarget < ActiveRecord::Migration
  def change
    add_column :targets, :jetdeck_id, :integer
  end
end
