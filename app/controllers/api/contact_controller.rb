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
    @response[:contacts] = []
    @user.contacts.each do |contact|
      @response[:contacts] << contact.to_json(:only=>[:id, :email, :phone, :display_name, :update_at, :status])
    end
    respond
  end

  def show
    @response[:contact] = @contact

    respond
  end

  private

  def load_contact
    @contact = Contact.find(params[:id])
  end    
end

