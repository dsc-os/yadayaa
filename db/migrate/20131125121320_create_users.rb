class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :uuid
      t.string :email
      t.string :encrypted_password
      t.integer :sign_in_count
      t.datetime :current_sign_in_at
      t.datetime :created_at
      t.datetime :updated_at
      t.string :display_name
      t.string :access_token
      t.timestamps
    end
  end
end
