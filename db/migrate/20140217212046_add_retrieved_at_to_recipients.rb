class AddRetrievedAtToRecipients < ActiveRecord::Migration
  def change
    add_column :recipients, :retrieved_at, :datetime
  end
end
