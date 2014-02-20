class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :user_id
      t.text :body
      t.string :audio_file_name
      t.boolean :delivered_to_all
      t.float :lat
      t.float :lon

      t.timestamps
    end
  end
end
