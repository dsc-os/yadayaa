class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.integer :user_id
      t.string :email
      t.string :phone
      t.string :display_name

      t.timestamps
    end
  end
end
