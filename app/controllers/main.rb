class Main < Sinatra::Application

  before do
    @current_name = session[:name]
    @current_user = Market::User.user_by_name(session[:name])
    @all_items = Market::Item.active_items
    @users = Market::User.all
    @errors = {}
  end

  get "/" do
    redirect '/login' unless session[:name]
    erb :marketplace
  end

  get "/strongpass" do
    erb :strongpass
  end

  get "/all_users" do
    redirect '/login' unless session[:name]
    erb :userlist
  end

  get "/profile/:id" do
    redirect '/login' unless session[:name]

    @user = Market::User.user_by_id(params[:id])
    @items = Market::Item.items_by_agent(@user)

    erb :userprofile
  end

  delete "/profile/:id" do
    redirect '/login' unless session[:name]

    @user = Market::User.user_by_id(params[:id]).delete

    redirect "/logout"
  end

  get "/error" do
    redirect '/login' unless session[:name]

    erb :error
  end

end
