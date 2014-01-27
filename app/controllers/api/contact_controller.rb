class Api::ContactController < ApiController

  before_filter :standard_response
  before_filter :auth
  
  def create
    @user.skip_validate_password = true
    @contact = Contact.create!(:display_name=>params[:display_name], 
                               :email=>params[:email],
                               :phone=>params[:phone],
                               :user=>@user)
    respond
  end

end

