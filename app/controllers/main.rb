include Market

class Main < Sinatra::Application

  before do
    @current_id = session[:user_id]
    @current_user = session[:user_id] ? Market::User.user_by_id(session[:user_id]) : nil
    @all_items = Market::Item.active_items
    @users = Market::User.all
    @errors = {}
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

  get "/profile/:id" do
    redirect '/login' unless session[:user_id]

    @user = Market::User.user_by_id(params[:id])
    @items = Market::Item.items_by_agent(@user)

    erb :userprofile
  end

  delete "/profile/:id" do
    redirect '/login' unless session[:user_id]

    @user = Market::User.user_by_id(params[:id]).delete

    redirect "/logout"
  end

  get "/organization/:id" do
    redirect '/login' unless session[:user_id]

    @org = Organization.organization_by_id(params[:id].to_i)
    @items = Item.items_by_agent(@org)

    halt erb :error, :locals => {:message => "no organization found"} unless @org

    erb :organization
  end

  get "/error" do
    redirect '/login' unless session[:user_id]

    erb :error
  end

end
