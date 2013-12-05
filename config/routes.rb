Yadayaa::Application.routes.draw do

  match "/api/:version/test" => 'api/system#test', :via=>[:get, :post]
  match "/api/:version/testuser" => 'api/system#testuser', :via=>[:get, :post]
  match "/api/:version/time" => 'api/system#time', :via=>[:get, :post]
  match "/api/:version/signin" => 'api/system#signin', :via=>[:post, :get]
  match "/api/:version/signout" => 'api/system#signout', :via=>[:post, :get]
  match "/api/:version/register" => 'api/system#register', :via=>[:post, :get]
  match "/api/:version/validate_display_name" => 'api/system#validate_display_name', :via=>[:post, :get]

  get "/" => "home#index"
end
