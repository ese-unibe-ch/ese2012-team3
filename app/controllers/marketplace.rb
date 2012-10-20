
  post "/item/:id/buy" do
    redirect '/login' unless session[:user_id]

    @item = Item.by_id(params[:id].to_i)
    
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

    if @current_user == @item.owner
      @item.inactivate if params[:new_state] == "inactive"
      @item.activate if params[:new_state] == "active"
    end
    redirect back
  end

  get "/item/create" do
    redirect '/login' unless session[:user_id]
    erb :create_item
  end

  post "/item/create" do
    redirect '/login' unless session[:user_id]

    #input validation
    @errors[:name] = "item must have a name!" if params[:name].empty?
    @errors[:price] = "item must have a price!" if params[:price].empty?
    @errors[:price] = "price must be a positive integer!" unless params[:price].to_i > 0
    image_file_check()

    #create item
    if @errors.empty?
      item_name = params[:name]
      item_price = params[:price].to_i
      item = Market::Item.init(:name   => item_name,
                        :price  => item_price,
                        :active => false,
                        :owner  => @current_user,
                        :about => params[:about]
      )
      item.image_file_name = add_image(ITEMIMAGESROOT, item.id)
      #display form with errors
    else
      halt erb :create_item
    end

    redirect @current_user.profile_route
  end

  post "/item/:item_id/edit" do
    @item = Item.by_id(params[:item_id].to_i)
    redirect '/login' unless session[:user_id] and @current_user == @item.owner

    #input validation
    @errors[:name] = "item must have a name!" if params[:name].empty?
    @errors[:price] = "item must have a price!" if params[:price].empty?
    @errors[:price] = "price must be a positive integer!" unless params[:price].to_i > 0
    image_file_check()

    if @errors.empty?
      @item.name = params[:name]
      @item.price = params[:price].to_i
      @item.about = params[:about]
      if params[:image_file]
        @item.delete_image_file
        @item.image_file_name = add_image(ITEMIMAGESROOT, @item.id)
      end
      redirect @current_user.profile_route
    #display form with errors
    else
      halt erb :edit_item
    end
    redirect @current_user.profile_route
  end

  get "/item/:id/edit" do
    redirect '/login' unless session[:user_id]

    @item = Item.by_id(params[:id].to_i)

    params[:name] = @item.name
    params[:price] = @item.price
    params[:about] = @item.about
    erb :edit_item
  end


  get "/item/:id" do
    redirect '/login' unless session[:user_id]

    @item = Item.by_id(params[:id].to_i)

    erb :item
  end



