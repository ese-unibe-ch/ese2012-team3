require 'erb'

class Main < Sinatra::Application

  get "/" do
    @current_user = Market::User.user_by_name(session[:name])
    @users = Market::User.all

    erb :marketplace
  end

  get "/all_users" do
    @current_user = Market::User.user_by_name(session[:name])
    @users = Market::User.all

    erb :userlist
  end

  get "/profile/:username" do
    @user = Market::User.user_by_name(params[:username])
    halt erb :error, :locals =>
        {:message => "User '#{params[:username]}' doesn't exist."} unless @user

    @current_user = Market::User.user_by_name(session[:name])

    erb :userprofile
  end

  get "/error" do
    erb :error
  end

  get "/strongpass" do

    erb :strongpass
  end
end
