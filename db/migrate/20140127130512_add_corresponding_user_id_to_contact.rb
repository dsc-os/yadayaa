class AddCorrespondingUserIdToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :corresponding_user_id, :integer
  end
end
