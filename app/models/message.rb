class Message < ActiveRecord::Base

  has_attached_file :audio
  validates_attachment :audio, :content_type=>{:content_type=>/\Aaudio\/.*\z/}
 
  validates :user_id, :presence=>true 
  belongs_to :user
  has_many :recipients

  def add_recipient(recipient)
    return unless recipient && recipient.strip!=''
    self.recipients << Recipient.new(:contact_id=>recipient)
    self.delivered_to_all = false
  end

  def deliver
    self.recipients.each do |r|
      r.deliver
    end
  end

  def check_delivered_to_all
    all_delivered = true
    self.recipients.each do |r|
      if r.delivered_at==nil
        all_delivered = false
        break
      end
    end
    self.delivered_to_all = true if all_delivered
    self.save
  end

end
