class AddInvitationSentAtToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :invitation_sent_at, :datetime
  end
end
