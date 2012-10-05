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
    redirect '/' if session[:name]

    username = params[:username]
    password = params[:password]
    passwordc = params[:passwordc]
    file = params[:image_file]

    if file
      MAXIMAGESIZE = 400*1024
      halt erb :error, :locals =>
          {:message => "Images file too large, may be #{MAXIMAGESIZE/1024} kB, is #{file[:tempfile].size/1024} kB"} if file[:tempfile].size > MAXIMAGESIZE
    end

    halt erb :error, :locals =>
        {:message => "No username or password given"} unless username && password
    halt erb :error, :locals =>
        {:message => "Password and retyped password don't match"} unless passwordc == password

    user = nil
    begin
      user = User.init(:name => username, :credit => 0, :password => password, :interests => params[:interests])
    rescue => e
      halt erb :error, :locals =>
          {:message => e.message}
    end

    file = params[:image_file]

    if file
      user.image_file_name = "#{user.id}"+File.extname(file[:filename])
      FileUtils::copy_file(file[:tempfile].path, File.join("app/public/userimages", user.image_file_name) )
    end

    session[:name] = username
    redirect "/?registered=true"
  end

  # TODO move
  get "/userimages/:userimgfname" do # we could also just make them request the right file
    send_file(File.join("app/public/userimages", params[:userimgfname]))
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
