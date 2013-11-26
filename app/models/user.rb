class User < ActiveRecord::Base

  def lazy_token
    return self.access_token if self.access_token

    self.access_token = Digest::MD5.hexdigest("#{self.id}|#{self.uuid}#{Time.now}")
    self.save
    return self.access_token
  end

end
