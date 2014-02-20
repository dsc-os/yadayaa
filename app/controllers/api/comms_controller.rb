class Api::CommsController < ApiController
  before_filter :standard_response
  before_filter :auth

  def send_message
    if request.get?
      @message = Message.new
      @message.recipients.build
    else
      raise Exception.new("recipient(s) missing") unless params[:recipient_ids]
      params[:message][:user_id] = @user.id
      m = Message.create(params[:message].permit(:audio, :body, :lat, :lon, :user_id))

      params[:recipient_ids].each do |r|
        m.add_recipient(r)
      end
      
      m.deliver

      respond
    end
  end

  def messages
    messages = []
    recipients = Recipient.includes(:message).joins(:contact).where("contacts.corresponding_user_id = ?", @user.id)
    recipients = recipients.where("retrieved_at is null") unless params[:include_retrieved]
    recipients = recipients.where("created_at > ?", params[:since]) if params[:since]
    
    recipients.all.each do |recipient|
      msg = {}
      msg[:id] = recipient.message.id
      msg[:sender] = @user.contacts.where(corresponding_user_id: recipient.message.user_id).first.display_name
      msg[:sender_id] = recipient.contact_id
      msg[:created] = recipient.message.created_at
      msg[:body] = recipient.message.body
      msg[:audio] = true unless recipient.message.audio_file_name==nil
      Recipient.find(recipient.id).update_attribute(:retrieved_at, Time.now)
      messages << msg 
    end
    @response[:messages] = messages
    respond
  end

  def message
    message = Message.where(id: params[:id]).first
    raise Exception.new("message not found") unless message
    recipient = message.recipients.includes(:contact).where("contacts.corresponding_user_id = ?", @user.id).references(:contact).first
    raise Exception.new("not a recipient of this message") unless recipient
    recipient.retrieved_at = Time.now
    recipient.save

    if params[:audio]
      raise Exception.new("no audio file") unless message.audio_file_name
      send_file message.audio.path
    else
      @response[:sender] = @user.contacts.where(corresponding_user_id: message.user_id).first.display_name
      @response[:sender_id] = recipient.contact_id
      @response[:created] = message.created_at
      @response[:body] = message.body
      @response[:audio] = true unless message.audio_file_name==nil

      respond
    end
  end
end
