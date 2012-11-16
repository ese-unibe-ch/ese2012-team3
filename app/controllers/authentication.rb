

  post "/login" do
    username = params[:name]
    password = params[:password]

    # error handling...
    @errors[:name] = "User '#{username}' does not exist"  unless Market::User.all_names.include?(username)
    @errors[:name] = "No username given"  unless username && username.length > 0
    @username = username unless @errors[:name] # restore
    @errors[:password] = "No password given"  unless password && password.length > 0

    user = Market::User.user_by_name(username)
    if @errors.empty?
      @errors[:password] = "Wrong password"  unless user.password == password
    end

    halt erb :login, :locals => {:username => params[:username] || ''}  unless @errors.empty?

    session[:user_id] = user.id

    #on init, the user is not active for any organization
    session[:organization_id] = nil
    redirect "/?alert=loggedin"
  end

  get "/login" do
    redirect '/' if session[:user_id]
	  @errors = {}

    erb :login, :locals => {:username => ''}
  end

  get "/logout" do
    session[:user_id] = nil
    session[:organization_id] = nil
    @current_user = nil
    @current_agent = nil

    redirect "/login"
  end

