class Api::ContactController < ApiController

  before_filter :standard_response
  before_filter :auth
  before_filter :load_contact, :only=>[:delete, :update, :show]

  def create
    @user.skip_validate_password = true
    @contact = Contact.create!(:display_name=>params[:display_name], 
                               :email=>params[:email],
                               :phone=>params[:phone],
                               :user=>@user)
    @response[:contact_id] = @contact.id
    respond
  end

  def delete
    @response[:contact_id] = @contact.id
    @contact.destroy
    respond
  end

  def update
    @contact.update_attributes!(:display_name=>params[:display_name])
    respond
  end

  def list
    @response[:contacts] = @user.contacts.map {|contact| contact.api_view}
    respond
  end

  def show
    @response[:contact] = @contact.api_view
    respond
  end

  def status_update
    @user.update_contact_status(params[:email], params[:phone], params[:status]) 
    respond
  end

  private

  def load_contact
    @contact = Contact.find(params[:id])
  end    
end

