class Api::SystemController < ApiController

  before_filter :auth, :except=>[:test, :time]
  before_filter :standard_response

  def command
    self.send(params[:command])
    respond
  end

  def test
    @response[:time] = Time.now
  end
 
  def testuser
    @response[:time] = Time.now
    @response[:user_id] = @user.id
  end 

  def time
    @response[:time] = Time.now
  end

  def register

  end
end
