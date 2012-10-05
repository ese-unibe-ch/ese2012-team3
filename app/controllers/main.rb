require 'erb'

class Main < Sinatra::Application

  get "/" do
    # redirect '/login' unless session[:name]

    @current_user = Market::User.user_by_name(session[:name])
    @users = Market::User.all

    erb :marketplace
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

    erb :userprofile
  end

  get "/error" do
    redirect '/login' unless session[:name]

    erb :error
  end

end
