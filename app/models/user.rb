require 'bcrypt'
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors[attribute] << (options[:message] || "is not an email")
    end
  end
end

class User < ActiveRecord::Base
  include BCrypt
  attr_accessor :password, :skip_validate_password
 
  DisplayNameFormat = /\A[a-z0-9\-\_\.]+\z/i
 
  validates :email, uniqueness: true, email:true, presence: true
  validates :password, presence:true, length: { in: 8..64, too_short: "Password must be at least 8 characters long" }, :if=>proc { should_validate_password? }
  validates :display_name, presence:true, length: { in: 2..64, too_short: "Display name must be at least 2 characters long"}, uniqueness: true, format: { with: DisplayNameFormat }

  before_save :encrypt_password
  after_save :clear_password

  def should_validate_password?
    !self.skip_validate_password
  end

  def encrypt_password
    if password.present?
      self.salt = BCrypt::Engine.generate_salt
      self.encrypted_password= BCrypt::Engine.hash_secret(password, salt)
    end
  end

  def password_ok?(password)
    self.encrypted_password == BCrypt::Engine.hash_secret(password, self.salt) 
  end

  def clear_password
    self.password = nil
  end

  def hash_password
    self.encrypted_password = Digest::MD5.hexdigest("#{self.email}-#{Time.now}-#{rand(1000000)}")
  end

  def lazy_token
    return self.access_token if self.access_token

    self.access_token = Digest::MD5.hexdigest("#{self.id}|#{self.email}#{Time.now}")
    self.save
    return self.access_token
  end

  def signed_in
    self.skip_validate_password = true
    self.sign_in_count ||= 0
    self.sign_in_count += 1
    self.current_sign_in_at = Time.now
    self.save!
  end

  def sign_out
    self.skip_validate_password = true
    self.current_sign_in_at = nil
    self.access_token = nil
    self.save!
  end
end
