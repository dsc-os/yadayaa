Yadayaa::Application.routes.draw do

  match "/api/:version/:command" => 'api/system#command', :via=>[:get, :post]

end
