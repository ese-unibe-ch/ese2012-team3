

  before do
    @current_id = session[:user_id]

    # The user that is currently logged in in this session
    @current_login = session[:user_id] ? Market::User.user_by_id(session[:user_id]) : nil

    # The user/agent we are working for (buying items)
    if session[:organization_id].nil?
      @current_user = session[:user_id] ? Market::User.user_by_id(session[:user_id]) : nil
    else
      @current_user = Organization.organization_by_id(session[:organization_id].to_i)
    end
    @all_items = Market::Item.active_items
    @users = Market::User.all + Market::Organization.all
    @errors = {}
  end

  def set_error(at, text)
    @errors = {}
    @errors[at] = text
  end

  get "/" do
    redirect '/login' unless @current_user
    erb :marketplace
  end

  get "/strongpass" do
    erb :strongpass
  end

  get "/all_users" do
    redirect '/login' unless session[:user_id]
    erb :userlist
  end

  get "/error" do
    erb :error
  end

