include Market

class Marketplace < Sinatra::Application

  post "/item/:id/buy" do
    redirect '/login' unless session[:user_id]

    @item = Item.by_id(params[:id].to_i)
    
    @current_user = User.user_by_id(session[:user_id])

    begin
      @current_user.buy_item(@item)
    rescue Exception => e
      halt erb :error, :locals => {:message => e.message}
    end

    #redirect back
    redirect "/?itembought=true"
  end

  post "/item/:id/status_change" do
    redirect '/login' unless session[:user_id]

    @item = Item.by_id(params[:id].to_i)
    @current_user = User.user_by_id(session[:user_id])

    if @current_user == @item.owner
      @item.inactivate if params[:new_state] == "inactive"
      @item.activate if params[:new_state] == "active"
    end
    redirect back
  end

  get "/item/create" do
    redirect '/login' unless session[:user_id]

    @errors = {}
    @current_user = Market::User.user_by_id(session[:user_id])

    erb :create_item
  end

  post "/item/create" do
    redirect '/login' unless session[:user_id]

    @current_user = Market::User.user_by_id(session[:user_id])

    #input validation
    @errors = {}
    @errors[:name] = "item must have a name!" if params[:name].empty?
    @errors[:price] = "item must have a price!" if params[:price].empty?
    @errors[:price] = "price must be a positive integer!" unless params[:price].to_i > 0

    #create item
    if @errors.empty?
      @current_user = Market::User.user_by_id(session[:user_id])
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

    redirect "/profile/#{@current_user.id}"
  end

  post "/item/:item_id/edit" do
    redirect '/login' unless session[:user_id]
    @item = Item.by_id(params[:item_id].to_i)
    @current_user = User.user_by_id(session[:user_id])

    #input validation
    @errors = {}
    @errors[:name] = "item must have a name!" if params[:item_name].empty?
    @errors[:price] = "item must have a price!" if params[:item_price].empty?
    @errors[:price] = "price must be a positive integer!" unless params[:item_price].to_i > 0

    if @errors.empty?
      if @current_user == @item.owner
        @item.name = params[:item_name]
        @item.price = params[:item_price]
      end
      redirect "/profile/#{@item.owner.id}"
    #display form with errors
    else
      halt erb :edit_item
    end
  end


  get "/item/:id/edit" do
    redirect '/login' unless session[:user_id]
    @item = Item.by_id(params[:id].to_i)
    @current_user = User.user_by_id(session[:user_id])
    @errors = {}
    erb :edit_item, :locals => {:item => @item}
  end


end
