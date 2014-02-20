module ApiHelper

  def include_token(user)
    hidden_field_tag "access_token", user.access_token
  end
end
