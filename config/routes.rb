Yadayaa::Application.routes.draw do

  get '/api/:version/contact/:id' => 'api/contact#show'
  post '/api/:version/contact' => 'api/contact#create'


  get "/api/:version/test" => 'api/system#test'
  get "/api/:version/testuser" => 'api/system#testuser'
  get "/api/:version/time" => 'api/system#time'

  delete "/api/:version/user" => 'api/system#delete_user'

  post "/api/:version/signin" => 'api/system#signin'
  post "/api/:version/signout" => 'api/system#signout'
  post "/api/:version/register" => 'api/system#register'
  get "/api/:version/validate_display_name/:display_name" => 'api/system#validate_display_name', :display_name=>/[^\/]+/
  post "/api/:version/profile" => 'api/system#update_profile'
  get "/api/:version/profile" => 'api/system#profile'
  post "/api/:version/password/:password" => 'api/system#change_password', :password=>/[^\/]+/
  get "/" => "home#index"
end
