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

  def signin
    post "/api/1/signin?email=contacttest@dsc.net&password=xxx"
    assert_ok_status
    json_response["access_token"]
  end

  test "fixtures" do
   assert_equal "testing", preferences(:mode).value
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

    post "/api/1/signin?email=esting@dsc.net&password=asdfasdf"
    assert_error_status
    assert_equal("incorrect email address or password", json_response["message"])
    post "/api/1/signin?email=testing@dsc.net&password=asdfasdf"
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
    assert_equal(json_response["user"]["home"],"4321")
    assert_equal(json_response["user"]["office"],"999")
    assert_equal(json_response["user"]["mobile"],"1234")
    assert_equal(json_response["user"]["homepage"],"xxx")

    delete "/api/1/user?access_token=#{access_token}"
    assert_ok_status
  end

  test "change password" do
    post "/api/1/register?email=zzz@dsc.net&display_name=testing&password=asdfasdf"
    assert_response :success
    assert_ok_status
    access_token = json_response["access_token"]
    post "/api/1/password?password=asdfasdfx&access_token=#{access_token}"
    assert_ok_status
    post "/api/1/signout?access_token=#{access_token}"
    assert_response :success
    assert_ok_status
    post "/api/1/signin?email=zzz@dsc.net&password=asdfasdfx"
    assert_response :success
    assert_ok_status
  end

  test "bad password" do
    post "/api/1/signin?email=contacttest@dsc.net&password=123"
    assert_error_status
  end
    
  test "create contacts" do 
    access_token = signin
    # bad contact add parameters
    post "/api/1/contact?access_token=#{access_token}"
    assert_error_status
    # good contact add
    post "/api/1/contact?access_token=#{access_token}&display_name=FredTest&email=fred@dsc.net"
    assert_ok_status
    contact = Contact.where(display_name: "FredTest").first
    assert_equal(contact.id, json_response["contact_id"])
    # bad contact because display_name is not unique
    post "/api/1/contact?access_token=#{access_token}&display_name=FredTest&email=fred2@dsc.net"
    assert_error_status

    # check user now has 1 test contact, with INVITED status
    u = User.where(email: "contacttest@dsc.net").first
    assert_equal(1, u.contacts.size)
    contact = u.contacts.first
    assert_equal('fred@dsc.net', contact.email)
    assert_equal('INVITED', contact.status)

     
    # if I add other@dsc.net to my contact list we should both be automatically confirmed, because 
    # other@dsc.net already has me in his contact list (by seed data) 
    Contact.where(display_name: "Seeded Test Contact").first.update_corresponding_user
    post "/api/1/contact?access_token=#{access_token}&display_name=TestContact&email=other@dsc.net"
    assert_ok_status
    contact = Contact.where(display_name: "TestContact").first
    assert_equal('CONFIRMED', contact.status)
    contact = Contact.where(display_name: "Seeded Test Contact").first
    assert_equal('CONFIRMED', contact.status)


    # if I add noncontacttest@dsc.net to my contact list the relationship should be PENDING
    # because though they exist, they don't have me on their contact list
    post "/api/1/contact?access_token=#{access_token}&display_name=TestContact2&email=noncontacttest@dsc.net"
    assert_ok_status
    contact = Contact.where(display_name: "TestContact2").first
    assert_equal('PENDING', contact.status)

  end
  
  test "delete contact" do
    access_token = signin

    Contact.where(display_name: "Seeded Test Contact").first.update_corresponding_user
    post "/api/1/contact?access_token=#{access_token}&display_name=TestContact3&email=other@dsc.net"
    assert_ok_status
    contact = Contact.where(display_name: "Seeded Test Contact").first
    assert_equal('CONFIRMED', contact.status)

    contact_id = json_response["contact_id"]

    delete "/api/1/contact/#{contact_id}?access_token=#{access_token}"
    assert_ok_status
    assert_equal(contact_id, json_response["contact_id"])
    contact = Contact.where(display_name: "Seeded Test Contact").first
    assert_equal('REMOVED', contact.status)
  end 

  test "edit contact" do 
    access_token = signin

    post "/api/1/contact?access_token=#{access_token}&display_name=TestContact4&email=other@dsc.net"
    contact_id = json_response["contact_id"]
    put "/api/1/contact/#{contact_id}?access_token=#{access_token}&display_name=TestContact4X"
    assert_ok_status
    new_contact = Contact.find(contact_id)
    assert_equal("TestContact4X", new_contact.display_name)
  end

  test "list contacts" do
    access_token = signin
    post "/api/1/contact?access_token=#{access_token}&display_name=TestContact4&email=other@dsc.net"
    get "/api/1/contacts?access_token=#{access_token}"
    assert_ok_status
    contact = JSON.parse(json_response["contacts"]).first
    assert_equal("TestContact4", contact["display_name"])
    post "/api/1/contact?access_token=#{access_token}&display_name=TestContact5&email=otherx@dsc.net"
    get "/api/1/contacts?access_token=#{access_token}"
    assert_equal(2, JSON.parse(json_response["contacts"]).size)
  end

  test "show contact" do
    return
    access_token = signin
    post "/api/1/contact?access_token=#{access_token}&display_name=TestContact5&email=other@dsc.net"
    contact_id = json_response["contact_id"]
    get "/api/1/contact/#{contact_id}?access_token=#{access_token}"
    assert_ok_status
    puts json_response["contact"]
    contact = JSON.parse(json_response["contact"])
    puts contact

  end


end




