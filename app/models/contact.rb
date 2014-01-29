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
    return nil unless self.corresponding_user_id

    # is this contacts owner in the list of this corresponding user's contacts
    self.corresponding_user.contacts.where("email = ? or phone = ? or phone = ? or phone = ?", search_field(self.user.email), search_field(self.user.mobile), search_field(self.user.office), search_field(self.user.home)).first
  end

  def update_corresponding_user
    return if self.corresponding_user_id
    param_email = search_field(self.email)
    param_phone = search_field(self.phone)
    u = User.where(["email = ? or mobile = ? or home = ? or office = ?", param_email, param_phone, param_phone, param_phone]).first
    return unless u

    update_column :corresponding_user_id, u.id
  end

  def one_contact_method
    if email==nil && phone==nil || ((email && email.length==0) && (phone && phone.length==0))
      errors.add(:email, "either email or phone must be specified")
    end
  end

  def update_status
    # A contact does however a system status which is not controlled by the user. This status is either CONFIRMED, INVITED, PENDING, REJECTED, REMOVED. A contact who has been added who is not yet a registered user themselves would have receive an invite to join and have the status INVITED. A contact who has been added who is a registered user, but does not have the user in their contact's list already will receive a message asking to add the user as a contact and have the status PENDING. A contact who has been added who is a registered user, who already has the user in their contact list will receive a message saying that the user has added them as a contact and will have a status of CONFIRMED.

    return if self.status=='CONFIRMED' || self.status=='REJECTED' || self.status=='REMOVED'

    if self.status==nil 
      if self.corresponding_user
        contact = self.co_contact
        if contact 
          make_co_contact(contact)
        else
          send_contact_invitation
        end
      else
        send_user_invitation
      end
    end
  end

  def make_co_contact(contact)
    update_column :status, "CONFIRMED"
    contact.update_column :status, "CONFIRMED"
  end
 
  def send_contact_invitation
    # email contact invite
    update_column(:status, "PENDING")
    update_column(:invitation_sent_at, Time.now)
  end

  def send_user_invitation
    # email user invite
    update_column(:status, "INVITED")
    update_column(:invitation_sent_at, Time.now)
  end

  private 

  # this is to be used for searching and we don't want to search for an empty value
  def search_field(v)
    v = "*" * 100 if v==nil || v.strip.length==0
    return v
  end
end
