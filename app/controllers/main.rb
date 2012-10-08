require 'erb'

class Main < Sinatra::Application

  get "/" do
    redirect '/login' unless session[:name]

    @current_user = Market::User.user_by_name(session[:name])
    @items = Market::Item.active_items

    erb :marketplace
  end

  get "/strongpass" do
    erb :strongpass
  end

  get "/all_users" do
    redirect '/login' unless session[:name]

    @current_user = Market::User.user_by_name(session[:name])
    @users = Market::User.all

    erb :userlist
  end

  get "/profile/:username" do
    redirect '/login' unless session[:name]

    @current_user = Market::User.user_by_name(session[:name])
    @user = Market::User.user_by_name(params[:username])
    @items = Market::Item.items_by_user(@user)

    erb :userprofile
  end

  delete "/profile/:username" do
    redirect '/login' unless session[:name]

    @current_user = Market::User.user_by_name(session[:name])
    @current_user.delete

    redirect "/logout"
  end

  get "/error" do
    redirect '/login' unless session[:name]

    erb :error
  end

end
