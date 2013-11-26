class ApiController < ApplicationController

  rescue_from Exception, :with => :error_render_method 

  protected

  def error_render_method(exception)
    @response[:status] = "ERROR"
    @response[:message] = exception.message

    respond
  end

  def auth
    if request.authorization
      user,password = ActionController::HttpAuthentication::Basic.decode_credentials(request).split(':')
      @user = User.where(:uuid=>user).where(:encrypted_password=>password).first
      @token = @user.lazy_token if @user
    else 
      @token = params[:access_token] 
      @user = User.where(:access_token=>token).first
    end

    unless @user 
      response.header["WWW-Authenticate"] = 'Basic realm="API"'
      render :json=>"not authorised", :status=>401 
    end
  end

  def token
    @token
  end

  def user
    @user
  end

  def standard_response
    @response = {}
    @response[:status] = "OK"
  end

  def respond
    render :json=>JSON.pretty_generate(@response)
  end

end
