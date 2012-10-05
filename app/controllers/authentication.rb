require 'erb'
def relative path
  File.join(File.dirname(__FILE__), path)
end
require relative('../../app/models/market/user')

class Authentication < Sinatra::Application

  post "/login" do
    username = params[:username]
    password = params[:password]

    halt erb :error, :locals =>
        {:message => "User #{username} does not exist"} unless Market::User.allNames.include?(username)
    halt erb :error, :locals =>
        {:message => "no username or password given"} unless username && password
    halt erb :error, :locals =>
        {:message => "wrong password"} unless username == password

    session[:name] = username
    redirect "/?loggedin=true"
  end

  get "/login" do
    redirect '/' if session[:name]

    @current_name = session[:name]

    erb :login
  end

  get "/logout" do
    session[:name] = nil
    redirect "/login"
  end

end
