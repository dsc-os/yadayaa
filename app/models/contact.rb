class Contact < ActiveRecord::Base
  belongs_to :user
  belongs_to :corresponding_user, :class_name=>"User"

  after_save :update_corresponding_user

  after_save :update_status

  validates :display_name, :presence=>true, :uniqueness=>{scope: :user_id}
  validates :user_id, :presence=>true
  validate :one_contact_method
  validates_associated :user

  def co_contact

  end

  def update_corresponding_user
    return if self.corresponding_user_id

    email = self.email
    email = "*" * 100 unless email && email.length>0
    phone = self.phone 
    phone = "*" * 100 unless phone && phone.length>0
    u = User.where("email = ? or mobile = ? or home = ? or office = ?", email, phone, phone, phone).first
    return unless u
    update_column :corresponding_user, u
  end

  def one_contact_method
    if email==nil && phone==nil || (email.length==0 && phone.length==0)
      errors.add(:email, "either email or phone must be specified")
    end
  end

  def update_status
    # A contact does however a system status which is not controlled by the user. This status is either CONFIRMED, INVITED, PENDING, REJECTED, REMOVED. A contact who has been added who is not yet a registered user themselves would have receive an invite to join and have the status INVITED. A contact who has been added who is a registered user, but does not have the user in their contact's list already will receive a message asking to add the user as a contact and have the status PENDING. A contact who has been added who is a registered user, who already has the user in their contact list will receive a message saying that the user has added them as a contact and will have a status of CONFIRMED.

    return if self.status=='CONFIRMED' || self.status=='REJECTED' || self.status=='REMOVED'

    if self.status==nil && self.corresponding_user && self.corresponding_user
      send_invitation
    elsif self.status==nil && 
    end
  end

 
  def send_invitation
    # email invite
    update_column(:status, "INIVITED")
    update_column(:invitation_sent_at, Time.now)
  end

end
