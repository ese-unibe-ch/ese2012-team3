
  post "/item/:id/buy" do
    # TODO: Create :buy activity in orgactivities if current_agent is an organization

    redirect '/login' unless session[:user_id]

    @item = Item.by_id(params[:id].to_i)
    
    begin
      @current_agent.buy_item(@item)
    rescue Exception => e
      halt erb :error, :locals => {:message => e.message}
    end

    #redirect back
    redirect back + "?alert=itembought"
  end

  post "/item/:id/status_change" do
    redirect '/login' unless session[:user_id]

    @item = Item.by_id(params[:id].to_i)

    if @current_agent == @item.owner
      @item.inactivate if params[:new_state] == "inactive"
      if params[:new_state] == "active"
        @item.activate

        #add to activity list
        @current_agent.add_activity(Activity.init({:creator => @current_agent,
                                                   :type => :activate,
                                                   :message => "activated #{@item.name}"}))
      end
    end

    redirect back
  end

  get "/item/create" do
    redirect '/login' unless session[:user_id]
    erb :create_item
  end

  post "/item/create" do
    # TODO: Create :createitem activity in orgactivities if current_agent is an organization

    redirect '/login' unless session[:user_id]

    #input validation
    @errors[:name] = "item must have a name!" if params[:name].empty?
    @errors[:price] = "item must have a price!" if params[:price].empty?
    @errors[:price] = "price must be a positive integer!" unless params[:price].to_i > 0
    @errors[:price] = "price has to be a number!" unless params[:price].match /^[0-9]*$/
    image_file_check()

    #create item
    if @errors.empty?
      item_name = params[:name]
      item_price = params[:price].to_i
      item = Market::Item.init(:name   => item_name,
                        :price  => item_price,
                        :active => false,
                        :owner  => @current_agent,
                        :about => params[:about]
      )
      item.image_file_name = add_image(ITEMIMAGESROOT, item.id)
      #display form with errors
    else
      halt erb :create_item
    end

    redirect @current_agent.profile_route
  end

  post "/item/:item_id/edit" do
    @item = Item.by_id(params[:item_id].to_i)
    redirect '/login' unless session[:user_id] and @current_agent == @item.owner

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
      redirect @current_agent.profile_route
    #display form with errors
    else
      halt erb :edit_item
    end

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

  post "/item/:id/add_comment" do
    redirect '/login' unless session[:user_id]

    #input validation
    @errors[:comment] = "comment must not be empty" if params[:comment].empty?

    @item = Item.by_id(params[:id].to_i)

    if @errors.empty?
      @item.add_comment(Comment.init(:creator => @current_agent, :text => params[:comment]))

      #add to activity list
      @current_agent.add_activity(Activity.init({:creator => @current_agent,
                                                 :type => :comment,
                                                 :message => "commented on #{@item.name}"}))

      redirect "/item/#{params[:id]}"
    else
      halt erb :item
    end
  end

  post "/item/:id/watchlist" do
    redirect '/login' unless session[:user_id]

    @item = Item.by_id(params[:id].to_i)
    if @current_agent.wishlist.include?(@item)
      @current_agent.remove_item_from_wishlist(@item)
    else
      @current_agent.add_item_to_wishlist(@item)
    end

    redirect "/item/#{@item.id.to_s}"
  end
