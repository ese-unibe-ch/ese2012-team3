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
        {:message => "User '#{username}' does not exist"} unless Market::User.allNames.include?(username)
    halt erb :error, :locals =>
        {:message => "No username or password given"} unless username && password
    halt erb :error, :locals =>
        {:message => "Wrong password"} unless Market::User.user_by_name(username).password == password

    session[:name] = username
    redirect "/?loggedin=true"
  end

  get "/login" do
    redirect '/' if session[:name]

    @current_name = session[:name]

    erb :login
  end

  post "/register" do
    username = params[:username]
    password = params[:password]
    passwordc = params[:passwordc]
    file = params[:image_file]

    halt erb :error, :locals =>
        {:message => "No username or password given"} unless username && password
    halt erb :error, :locals =>
        {:message => "Password and retyped password don't match"} unless passwordc == password

    begin
      User.init(:name => username, :credit => 0, :password => password)
    rescue => e
      halt erb :error, :locals =>
          {:message => e.message}

    end


    session[:name] = username
    redirect "/?registered=true"
  end

  get "/register" do
    redirect '/' if session[:name]

    erb :register
  end

  get "/logout" do
    session[:name] = nil
    redirect "/login"
  end

end
