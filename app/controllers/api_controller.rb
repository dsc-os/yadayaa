class ApiController < ApplicationController

  rescue_from Exception, :with => :error_render_method 

  protected

  def validate_mode(mode)
    if mode!=Preference.get("server mode").value
      raise Exception.new("command not available in the current mode '#{Preference.get('server mode').value}'")
    end
  end

  def error_render_method(exception)
    standard_response if @response == nil
    @response[:status] = "error"
    @response[:message] = exception.message

    respond
  end

  def auth
    if request.authorization
      user,password = ActionController::HttpAuthentication::Basic.decode_credentials(request).split(':')
      logger.debug "HTTP Authentication user: '#{user}'"
      @user = User.where(:email=>user).first
      if @user && @user.password_ok?(password)
        @token = @user.lazy_token 
      end
    else 
      @token = params[:access_token] 
      @user = User.where(:access_token=>token).first if @token
    end

    unless @user 
      response.header["WWW-Authenticate"] = 'Basic realm="API"'
      @status = 401
      @response[:status] = "error"
      respond
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
    @response[:status] = "ok"
    @status = 200
  end

  def respond
    render :json=>JSON.pretty_generate(@response), :status=>@status
  end

end
