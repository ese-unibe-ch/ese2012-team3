include Market

class Main < Sinatra::Application

  before do
    @current_id = session[:user_id]
    @current_user = session[:user_id] ? Market::User.user_by_id(session[:user_id]) : nil
    @all_items = Market::Item.active_items
    @users = Market::User.all + Market::Organization.all
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
  
  get "/settings" do
    redirect '/login' unless session[:user_id]
    erb :settings
  end

  get "/profile/:id" do
    redirect '/login' unless session[:user_id]

    begin
      @user = Market::User.user_by_id(params[:id])
    rescue
      halt erb :error, :locals => {:message => "no user found to id #{params[:id]}"} unless @user
    end

    @items = Market::Item.items_by_agent(@user)

    erb :userprofile
  end

  delete "/profile/:id" do
    redirect '/login' unless session[:user_id]

    @user = Market::User.user_by_id(params[:id]).delete

    redirect "/logout"
  end

  get "/delete_confirmation" do
    erb :delete_confirmation
  end

  get "/organization/:id" do
    redirect '/login' unless session[:user_id]

    @org = Organization.organization_by_id(params[:id].to_i)
    halt erb :error, :locals => {:message => "no organization found to id #{params[:id]}"} unless @org

    @items = Item.items_by_agent(@org)
    addable_users = User.all.select {|u| !u.is_member_of?(@org)}

    erb :organization, :locals => {:addable_users   => addable_users}
  end

  post "/organization/:id/add_member" do
    redirect '/login' unless session[:user_id]

    @org = Organization.organization_by_id(params[:id].to_i)
    halt erb :error, :locals => {:message => "no organization found"} unless @org

    user_to_add = User.user_by_id(params[:user_to_add])
    halt erb :error, :locals => {:message => "no user found to add"} unless user_to_add

    begin
      @org.add_member(user_to_add)
    rescue RuntimeError => e
      halt erb :error, :locals => {:message => e.message}
    end

    redirect "/organization/#{params[:id]}"
  end

  post "/organization/:id/remove_member" do
    redirect '/login' unless session[:user_id]

    @org = Organization.organization_by_id(params[:id].to_i)
    halt erb :error, :locals => {:message => "no organization found"} unless @org

    begin
      user_to_remove = User.user_by_id(params[:user_to_remove])
    rescue RuntimeError
      halt erb :error, :locals => {:message => "no user found to remove"} unless user_to_remove
    end

    begin
      @org.remove_member(user_to_remove)
    rescue RuntimeError => e
      halt erb :error, :locals => {:message => e.message}
    end

    redirect "/organization/#{params[:id]}"
  end

  get "/error" do
    redirect '/login' unless session[:user_id]

    erb :error
  end

end
