class Api::SystemController < ApiController

  before_filter :standard_response
  before_filter :auth, :except=>[:test, :time, :register, :signin, :validate_display_name]

  def validate_display_name
    name = params[:display_name]
    raise Exception.new("display_name missing") unless name
    raise Exception.new("too short") if name.length<2
    raise Exception.new("too long") if name.length>64
    raise Exception.new("invalid characters") unless name =~ User::DisplayNameFormat
    raise Exception.new("taken") if User.where(:display_name=>name.downcase).count > 0
    respond
  end

  def test
    @response[:time] = Time.now
    respond
  end
 
  def testuser
    @response[:time] = Time.now
    @response[:user_id] = @user.id
    respond
  end 

  def time
    @response[:time] = Time.now
    respond
  end

  def delete_user
    validate_mode("testing")

    @user.destroy
    respond
  end

  def signin
    @user = User.where(:email=>params[:email]).first
    if @user && @user.password_ok?(params[:password])
      @response[:access_token] = @user.lazy_token
      @user.signed_in
    else
      @user = nil
    end
   
    unless @user
     @status = 401
     raise Exception.new("incorrect email address or password") 
    end

    respond
  end

  def signout
    @user.sign_out
    respond
  end 

  def register
    @user = User.create!(:password=>params[:password], :email=>params[:email], :display_name=>params[:display_name])
    @user.signed_in
    @response[:access_token] = @user.lazy_token
    respond
  end

  def update_profile
    @user.mobile = params[:mobile] if params[:mobile]
    @user.office = params[:office] if params[:office]
    @user.home = params[:home] if params[:home]
    @user.homepage = params[:homepage] if params[:homepage]
    @user.save_without_password!

    respond
  end

  def profile
    @response[:user] = { :mobile => @user.mobile, :office=> @user.office, :home=>@user.home, :homepage=>@user.homepage }

    respond
  end

  def change_password
    @user.password = params[:password]
    @user.save!

    respond
  end
end
