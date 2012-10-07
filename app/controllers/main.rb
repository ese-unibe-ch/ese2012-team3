require 'erb'

class Main < Sinatra::Application

  get "/" do
    redirect '/login' unless session[:name]

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

  get "/item/create" do
    redirect '/login' unless session[:name]

    @errors = {}
    @current_user = Market::User.user_by_name(session[:name])

    erb :create_item
  end

  post "/item/create" do
    redirect '/login' unless session[:name]

    @current_user = Market::User.user_by_name(session[:name])

    #input validation
    @errors = {}
    @errors[:name] = "item must have a name!" if params[:name].empty?
    @errors[:price] = "item must have a price!" if params[:price].empty?
    @errors[:price] = "price must be a positive integer!" unless params[:price].to_i > 0

    #create item
    if @errors.empty?
      @current_user = Market::User.user_by_name(session[:name])
      item_name = params[:name]
      item_price = params[:price].to_i
      Market::Item.init(:name   => item_name,
                        :price  => item_price,
                        :active => false,
                        :owner  => @current_user)
    #display form with errors
    else
      halt erb :create_item
    end

    redirect "/profile/#{@current_user.name}"
  end

end
