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

    # and that that user has been created
    u = User.where(email: "fred@dsc.net").first
    assert_equal('INVITED', u.status)

     
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
    contacts = json_response["contacts"]
    contact = contacts.first
    assert_equal("TestContact4", contact["display_name"])
    post "/api/1/contact?access_token=#{access_token}&display_name=TestContact5&email=otherx@dsc.net"
    get "/api/1/contacts?access_token=#{access_token}"
    contacts = json_response["contacts"]
    assert_equal(2, contacts.size)
  end

  test "show contact" do
    access_token = signin
    post "/api/1/contact?access_token=#{access_token}&display_name=TestContact5&email=other@dsc.net"
    contact_id = json_response["contact_id"]
    get "/api/1/contact/#{contact_id}?access_token=#{access_token}"
    assert_ok_status
    contact = json_response["contact"]
    assert_equal("TestContact5", contact["display_name"])

    get "/api/1/contact/9999999?access_token=#{access_token}"
    assert_error_status
  end

  test "invitation response" do 
    user_1 = User.where(:email=>"noncontacttest@dsc.net").first
    user_2 = User.where(:email=>"contacttest@dsc.net").first

    access_token = signin
    # add contact who is an existing user
    post "/api/1/contact?access_token=#{access_token}&display_name=TestContact6&email=noncontacttest@dsc.net"
    contact_id = json_response["contact_id"]
    get "/api/1/contact/#{contact_id}?access_token=#{access_token}"
    contact = json_response["contact"]
    assert_equal("TestContact6", contact["display_name"])
    assert_equal("PENDING", contact["status"])

    post "/api/1/signin?email=noncontacttest@dsc.net&password=xxx"
    assert_ok_status
    access_token = json_response["access_token"]
    post "/api/1/contact/accept?access_token=#{access_token}&email=contacttest@dsc.net&status=ACCEPT"
    contact_1 = User.find(user_1).contacts.first
    contact_2 = User.find(user_2).contacts.first

    # both should be confirmed now
    assert_equal("CONFIRMED", contact_1.status)
    assert_equal("CONFIRMED", contact_2.status)

  end


end





