class Authentication < Sinatra::Application

  post "/login" do
    username = params[:username]
    password = params[:password]

    halt erb :error, :locals =>
        {:message => "User '#{username}' does not exist"} unless Market::User.allNames.include?(username)
    halt erb :error, :locals =>
        {:message => "No username or password given"} unless username && password
    user = Market::User.user_by_name(username)
    halt erb :error, :locals =>
        {:message => "Wrong password"} unless user.password == password

    session[:user_id] = user.id
    redirect "/?loggedin=true"
  end

  get "/login" do
    redirect '/' if session[:user_id]

    erb :login
  end

  def passwordcheck(password, passwordc, username, oldpass)

    halt erb :error, :locals =>
        {:message => "No password given"} unless password
    halt erb :error, :locals =>
        {:message => "Password and retyped password don't match"} unless passwordc == password

    begin
      PasswordCheck::ensure_password_strong(password, username, oldpass)
    rescue => e
      halt erb :error, :locals =>
          {:message => e.message}
    end
  end

  post "/register" do
    redirect '/' if session[:user_id]

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
        {:message => "No username given"} unless username && password

    passwordcheck(password, passwordc,username, "")

    user = nil
    begin
      user = User.init(:name => username, :credit => 200,  # Whatever
                       :password => password, :about => params[:about])
    rescue => e
      halt erb :error, :locals =>
          {:message => e.message}
    end

    file = params[:image_file]

    if file
      user.image_file_name = "#{user.id}"+"_"+(file[:filename])
      FileUtils::cp(file[:tempfile].path, File.join(File.dirname(__FILE__),"../public/userimages", user.image_file_name) )
    end

    session[:user_id] = user.id
    redirect "/?registered=true"
  end

  # TODO move
  get "public/userimages/:userimgfname" do # we could also just make them request the right file
    send_file(File.join(File.dirname(__FILE__),"../public/userimages", params[:userimgfname]))
  end

  get "/register" do
    redirect '/' if session[:user_id]

    erb :register
  end

  post "/change_password" do
    user = Market::User.user_by_id(session[:user_id])

    #halt erb :error, :locals =>
    #    {:message => "N"} unless user

    password = params[:password]
    passwordc = params[:passwordc]
    currentpassword = params[:currentpassword]

    halt erb :error, :locals =>
        {:message => "Current password is wrong"} unless user.password == currentpassword

    passwordcheck(password, passwordc, user.name, currentpassword)
    user.password = password

    redirect "/?pwchanged=true"
  end

  get "/logout" do
    session[:user_id] = nil
    redirect "/login"
  end

end
