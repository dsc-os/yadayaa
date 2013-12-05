class DropUuid < ActiveRecord::Migration
  def change
    remove_column :users, :uuid
  end
end
