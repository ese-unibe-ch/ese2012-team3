class Main < Sinatra::Application

  get "/" do
    redirect '/login' unless session[:user_id]

    @current_user = Market::User.user_by_id(session[:user_id])
    @items = Market::Item.active_items

    erb :marketplace
  end

  get "/strongpass" do
    erb :strongpass
  end

  get "/all_users" do
    redirect '/login' unless session[:user_id]

    @current_user = Market::User.user_by_id(session[:user_id])
    @users = Market::User.all

    erb :userlist
  end

  get "/profile/:id" do
    redirect '/login' unless session[:user_id]

    @current_user = Market::User.user_by_id(session[:user_id])
    @user = Market::User.user_by_id(params[:id])
    @items = Market::Item.items_by_agent(@user)

    erb :userprofile
  end

  delete "/profile/:id" do
    redirect '/login' unless session[:user_id]

    @user = Market::User.user_by_id(params[:id]).delete

    redirect "/logout"
  end

  get "/error" do
    redirect '/login' unless session[:user_id]

    erb :error
  end

end
