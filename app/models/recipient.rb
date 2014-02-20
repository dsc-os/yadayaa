class Recipient < ActiveRecord::Base

  belongs_to :contact
  belongs_to :message

  validates :message_id, :presence=>true
  validates :contact_id, :presence=>true

  def deliver
    logger.debug "Send APNS for user #{self.contact.corresponding_user.display_name} with message_id #{self.message_id}"    

    self.delivered_at = Time.now
    self.save
    self.message.check_delivered_to_all
  end
end
