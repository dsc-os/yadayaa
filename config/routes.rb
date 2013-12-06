Yadayaa::Application.routes.draw do

  get "/api/:version/test" => 'api/system#test'
  get "/api/:version/testuser" => 'api/system#testuser'
  get "/api/:version/time" => 'api/system#time'
  post "/api/:version/signin/:email/:password" => 'api/system#signin', :email => /[^\/]+/, :password => /[^\/]+/
  post "/api/:version/signout" => 'api/system#signout'
  post "/api/:version/register" => 'api/system#register'
  get "/api/:version/validate_display_name/:display_name" => 'api/system#validate_display_name', :display_name=>/[^\/]+/
  post "/api/:version/profile" => 'api/system#update_profile'
  get "/api/:version/profile" => 'api/system#profile'
  post "/api/:version/password/:password" => 'api/system#change_password', :password=>/[^\/]+/
  get "/" => "home#index"
end
