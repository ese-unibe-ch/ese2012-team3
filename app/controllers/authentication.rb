class Authentication < Sinatra::Application

  before do
    @current_name = session[:name]
    puts session[:name].to_s
    @current_user = Market::User.user_by_name(session[:name])
    @errors = {}
  end

  post "/login" do
    username = params[:username]
    password = params[:password]

    # error handling...
    @errors[:name] = "User '#{username}' does not exist"  unless Market::User.allNames.include?(username)
    @errors[:name] = "No username given"  unless username && username.length > 0
    @username = username unless @errors[:name] # restore
    @errors[:password] = "No password given"  unless password && password.length > 0
    if @errors.empty?
      @errors[:password] = "Wrong password"  unless Market::User.user_by_name(username).password == password
    end
    halt erb :login unless @errors.empty?

    session[:name] = username
    redirect "/?loggedin=true"
  end

  get "/login" do
    redirect '/' if session[:name]
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

  def register_error(at, text)
    @errors[at] = text
    halt erb :register
  end

  # TODO Restore previous input in interests and username field on failure...
  post "/register" do
    redirect '/' if session[:name]

    username = params[:username]
    password = params[:password]
    passwordc = params[:passwordc]
    file = params[:image_file]

    if file
      MAXIMAGESIZE = 400*1024
      register_error :image_file,
                     "Image file too large, must be < #{MAXIMAGESIZE/1024} kB, is #{file[:tempfile].size/1024} kB" if file[:tempfile].size > MAXIMAGESIZE
    end

    # ======================= Error handling... basically copy of what exceptions already do, but with categorizing
    # TODO think of better way
    register_error :name, "No username given" unless username && username.size > 0
    register_error :name, "User with given username already exists" if Market::User.user_by_name(params[:name])

    register_error :pwinput, "No password given" unless password && password.size > 0
    register_error :pwcinput, "No password confirmation given" unless password && password.size > 0
    register_error :pwcinput, "Password and retyped password don't match" unless passwordc == password

    begin
      PasswordCheck::ensure_password_strong(password, username, "")
    rescue => e
      register_error :pwinput, e.message
    end

    #passwordcheck(password, passwordc,username, "")   # cannot use

    # =========================
    user = nil
    begin
      user = User.init(:name => username, :credit => 200,  # Whatever
                       :password => password, :about => params[:about])
    rescue => e  # should not fail here anymore...
      halt erb :error, :locals =>
          {:message => "Unexpected: "+e.message}
    end

    file = params[:image_file]

    if file
      user.image_file_name = "#{user.id}"+"_"+(file[:filename])
      FileUtils::cp(file[:tempfile].path, File.join(File.dirname(__FILE__),"../public/userimages", user.image_file_name) )
    end

    session[:name] = username
    redirect "/?registered=true"
  end

  # TODO move
  get "public/userimages/:userimgfname" do # we could also just make them request the right file
    send_file(File.join(File.dirname(__FILE__),"../public/userimages", params[:userimgfname]))
  end

  get "/register" do
    redirect '/' if session[:name]
    erb :register
  end

  post "/change_password" do
    #halt erb :error, :locals =>
    #    {:message => "N"} unless @current_user

    password = params[:password]
    passwordc = params[:passwordc]
    currentpassword = params[:currentpassword]

    halt erb :error, :locals =>
            {:message => "Current password is wrong"} unless @current_user.password == currentpassword

    passwordcheck(password, passwordc, session[:name], currentpassword)
    @current_user.password = password

    redirect "/?pwchanged=true"
  end

  get "/logout" do
    session[:name] = nil
    redirect "/login"
  end

end
