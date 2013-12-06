require 'test_helper'

class ApiTest < ActionDispatch::IntegrationTest

  def json_response
    ActiveSupport::JSON.decode @response.body
  end

  def assert_error_status
    assert_equal("error", json_response["status"], json_response["message"])
  end

  def assert_ok_status
    assert_equal("ok", json_response["status"], json_response["message"])
  end
  
  test "test" do 
    get "/api/1/test"
    assert_response :success
  end

  test "testuser" do 
    get "/api/1/testuser"
    assert_response 401
  end

  test "validate_display_name rejection" do 
    get "/api/1/validate_display_name/name1"
    assert_error_status
    assert_equal("taken", json_response["message"], json_response["message"])
  end

  test "validate_display_name success" do 
    get "/api/1/validate_display_name/name100"
    assert_ok_status
  end

  test "register with no password" do 
    post "/api/1/register?email=test@dsc.net&display_name=asdfasdf"
    assert_error_status
  end

  test "register existing user" do 
    post "/api/1/register?email=name1@dsc.net&display_name=asdfasdf&password=asdfasdf"
    assert_error_status
  end

  test "register new user and login" do 
    post "/api/1/register?email=testing@dsc.net&display_name=testing&password=asdfasdf"
    assert_ok_status
    access_token = json_response["access_token"]
    assert_not_nil(access_token)
    get "/api/1/testuser?access_token=#{access_token}"
    assert_response :success
    assert_ok_status
    
    post "/api/1/signout?access_token=#{access_token}"
    assert_ok_status
    get "/api/1/testuser?access_token=#{access_token}"
    assert_response 401

    post "/api/1/signin/esting@dsc.net/asdfasdf"
    assert_error_status
    assert_equal("incorrect email address or password", json_response["message"])
    post "/api/1/signin/testing@dsc.net/asdfasdf"
    assert_response :success
    assert_ok_status
  end

  test "user profile" do 
    post "/api/1/register?email=xxx@dsc.net&display_name=testing&password=asdfasdf"
    assert_ok_status 
    access_token = json_response["access_token"]
    post "/api/1/profile?access_token=#{access_token}&mobile=1234&home=4321&office=999&homepage=xxx"
    assert_ok_status
    get "/api/1/profile?access_token=#{access_token}"
    puts @response.body
    assert_equal(json_response["user"]["home"],"4321")
    assert_equal(json_response["user"]["office"],"999")
    assert_equal(json_response["user"]["mobile"],"1234")
    assert_equal(json_response["user"]["homepage"],"xxx")
  end

  test "change password" do
    post "/api/1/register?email=zzz@dsc.net&display_name=testing&password=asdfasdf"
    assert_response :success
    assert_ok_status
    access_token = json_response["access_token"]
    post "/api/1/password/asdfasdfx?access_token=#{access_token}"
    assert_ok_status
    post "/api/1/signout?access_token=#{access_token}"
    assert_response :success
    assert_ok_status
    post "/api/1/signin/zzz@dsc.net/asdfasdfx"
    assert_response :success
    assert_ok_status
  end

end
