Yadayaa::Application.routes.draw do

  match "/api/:version/test" => 'api/system#test', :via=>[:get, :post]
  match "/api/:version/testuser" => 'api/system#test', :via=>[:get, :post]
  match "/api/:version/time" => 'api/system#time', :via=>[:get, :post]

end
