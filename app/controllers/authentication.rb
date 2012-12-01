

  post "/login" do
    username = params[:name]
    password = params[:password]

    # error handling...
    @errors[:name] = LocalizedMessage.new([
                                              LocalizedMessage::LangKey.new("USER"),
                                              " '#{username}' ",
                                              LocalizedMessage::LangKey.new("DOES_NOT_EXIST")])   unless Market::User.all_names.include?(username)
    #"User '#{username}' does not exist"
    @errors[:name] = LocalizedMessage.new([LocalizedMessage::LangKey.new("NO_USERNAME_GIVEN")]) unless username && username.length > 0
    @username = username unless @errors[:name] # restore
    @errors[:password] = LocalizedMessage.new([LocalizedMessage::LangKey.new("NO_PASSWORD_GIVEN")])  unless password && password.length > 0

    user = Market::User.user_by_name(username)
    if @errors.empty?
      @errors[:password] = LocalizedMessage.new([LocalizedMessage::LangKey.new("WRONG_PASSWORD")])  unless user.password == password
    end

    halt erb :login, :locals => {:username => params[:username] || ''}  unless @errors.empty?
    session[:user_id] = user.id

    #on init, the user is not active for any organization
    session[:organization_id] = nil
    flash[:success] = 'logged_in'
    redirect '/'
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

