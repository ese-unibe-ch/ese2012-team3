
  post "/item/:id/buy" do
    redirect '/login' unless session[:user_id]

    @item = Item.by_id(params[:id].to_i)
    
    begin
      @current_agent.buy_item(@item)
    rescue Exception => e
      halt erb :error, :locals => {:message => e.message}
    end
    # If the user buys an item in the name of an organization, an organization activity is created.
    if @current_user != @current_agent
      @current_agent.add_orgactivity(Activity.init({:creator => @current_user,
                                                    :type => :buy,
                                                    :message => "bought item #{@item.name}"}))
    end

    session[:last_bought_item_id] = @item.id
    flash[:success] = 'item_bought'

    redirect back
  end

  get "/item/:id/create_auction" do
    redirect '/login' unless session[:user_id]

    erb :create_auction, :locals => { :item => checkAndGetItem(params[:id]) }
  end

  # Creates a time object from a different time
  # format
  #
  # replaces the method that only parsed the
  # dd.mm.yyyy hh:mm format
  #
  #Expected format
  #
  # Thu Nov 22 17:41:00 +0100 2012
  # dd.mm.yyyy hh:mm
  #
  def paramToTime(end_time)
    date = DateTime.parse(end_time)
    Time.local(date.year, date.month, date.day, date.hour, date.min, date.sec)
  end

  #
  # Called from create_auction view
  #
  # Expects
  # params[:minimal_price]: Minimal price for auction as a positive integer
  # params[:increment]: Increment for auction as a positive integer
  # params[:end_time]: Time (at the moment in seconds from now)
  #

  post "/item/:id/auction/create" do
    @item = checkAndGetItem(params[:id].to_i)
    end_time = paramToTime(params[:end_time])

    #Input validation
    @errors[:increment] = "increment must be set" if params[:increment].empty?
    @errors[:end_time] = "end time must be set" if params[:end_time].empty?
    @errors[:minimal_price] = "minimal price must be set" if params[:minimal_price].empty?
    @errors[:increment] = "increment must be positive integer" unless params[:increment] =~ /^[0-9]+$/
    @errors[:increment] = "increment must be more than zero" if params[:increment] == "0"
    @errors[:minimal_price] = "minimal price must be positive integer" unless params[:minimal_price] =~ /^[0-9]+$/
    @errors[:end_time] = "time must be in future" unless end_time > Time.now

    if (@errors.empty?)
      @item.auction = Auction.create(@item, params[:minimal_price].to_i, params[:increment].to_i, end_time)
    else
      halt erb :create_auction, :locals => { :item => @item }
    end
    redirect "/item/#{@item.id}"
  end

  get "/item/:id/auction" do
    item = Item.by_id(params[:id].to_i)

    if (item.auction.nil?)
      #make redirect with alert
      flash['error'] = 'no_auction'
      redirect '/'
    end

    params[:bid] = item.auction.minimal_bid
    erb :auction, :locals => { :item => item }
  end

  post "/item/:id/bid" do
    item =  Item.by_id(params[:id].to_i)
    agent = @current_agent
    price = params[:bid].to_i

    if (item.auction.nil?)
      #make redirect with alert
      flash['error'] = 'auction_over'
      redirect back
    end

    @errors[:bid] = "This bid has been already given, choose an higher one" if item.auction.already_bid?(price.to_i)
    @errors[:bid] = "The bid must be at least the current price + increment" if !item.auction.valid_bid?(price.to_i)
    @errors[:bid] = "You don't have enough money!" if price > agent.credit

    if (@errors.empty?)
      item.auction.bid(agent, price) unless (@current_agent == item.owner)
    else
      halt erb :auction,  :locals => {:item => item }
    end

    redirect "item/#{params[:id]}/auction"
  end

  #
  # Checks if an item can be retrieved and if the retrieved item
  # is owned by current agent if not redirects to where the
  # call was coming from or to '/' and shows an error.
  #

  def checkAndGetItem(id)
    item = Item.by_id(id.to_i)

    raise "item does not exist" if item.nil?
    raise "thats not your item!" if @current_agent != item.owner

    item
  end

  get "/item/:id/auction/edit" do
    @item = checkAndGetItem(params[:id].to_i)

    #Passing parameters
    params[:minimal_price] = @item.auction.minimal_price
    params[:end_time] = @item.auction.end_time.strftime("%d.%m.%Y %H:%M")
    params[:increment] = @item.auction.increment
    erb :edit_auction, :locals => { :item => Item.by_id(params[:id].to_i) }
  end

  #
  # Called from edit_auction view
  #
  # Expects
  # params[:minimal_price]: Minimal price for auction as a positive integer
  # params[:increment]: Increment for auction as a positive integer
  # params[:end_time]: Time (at the moment in seconds from now)
  #
  post "/item/:id/auction/edit" do
    @item = checkAndGetItem(params[:id].to_i)
    end_time = paramToTime(params[:end_time])

    #Input validation  (same as in create)
    @errors[:increment] = "increment must be set" if params[:increment].empty?
    @errors[:end_time] = "end time must be set" if params[:end_time].empty?
    @errors[:minimal_price] = "minimal price must be set" if params[:minimal_price].empty?
    @errors[:increment] = "increment must be positive integer" unless params[:increment] =~ /^[0-9]+$/
    @errors[:increment] = "increment must be more than zero" if params[:increment] == "0"
    @errors[:minimal_price] = "minimal price must be positive integer" unless params[:minimal_price] =~ /^[0-9]+$/
    @errors[:end_time] = "time must be in future" unless end_time > Time.now

    if (@errors.empty?)
      @item.auction.minimal_price = params[:minimal_price].to_i
      @item.auction.increment = params[:increment].to_i
      @item.auction.end_time= end_time unless end_time == @item.auction.end_time
    else
      halt erb :edit_auction, :locals => { :item => @item }
    end

    redirect "/item/#{@item.id}"
  end

  post "/item/:id/status_change" do
    redirect '/login' unless session[:user_id]

    @item = Item.by_id(params[:id].to_i)
    # Check for illegal activation
    if @current_agent == @item.owner
      # new_state is provided by the form
      @item.inactivate if params[:new_state] == "inactive"
      if params[:new_state] == "active"
        @item.activate

        #add to activity list of the agent
        @current_agent.add_activity(Activity.init({:creator => @current_agent,
                                                   :type => :activate,
                                                   :message => "activated #{@item.name}"}))
        # If the user activates an item in the name of an organization, an organization activity is created.
        if @current_user != @current_agent
          @current_agent.add_orgactivity(Activity.init({:creator => @current_user,
                                                        :type => :activate,
                                                        :message => "activated item #{@item.name}"}))
        end

      end
    end

    redirect back
  end

  get "/item/offer" do
    redirect '/login' unless session[:user_id]
    erb :create_offer
  end

  post "/item/offer" do
    redirect '/login' unless session[:user_id]

    #input validation
    @errors[:name] = "item must have a name!" if params[:name].empty?
    @errors[:price] = "item must have a price!" if params[:price].empty?
    @errors[:price] = "price must be a positive integer!" unless params[:price].to_i > 0
    @errors[:price] = "item must have a price!" if params[:price].empty?
    image_file_check()

    if @errors.empty?
      safe = Safe.new
      safe.fill(@current_agent, params[:price].to_i)
      offer = Market::Item.init(:name => params[:name],
                                :price => params[:price].to_i,
                                :owner => @current_agent,
                                :about => params[:about],
                                :offer => true,
                                :safe => safe)
      Market::Item.add_offer(offer)
      redirect '/'
    else
      halt erb :create_offer
    end
  end

  post "/item/:item_id/sell" do
    offeritem = Market::Item.offer_by_id(params[:item_id].to_i)
    Market::Item.transform_offer_to_item(offeritem)
    @current_agent.credit += offeritem.safe.savings
    redirect '/'
  end

  get "/item/create" do
    redirect '/login' unless session[:user_id]
    erb :create_item
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
      # If the user creates an item in the name of an organization, an organization activity is created.
      if @current_user != @current_agent
        @current_agent.add_orgactivity(Activity.init({:creator => @current_user,
                                                      :type => :createitem,
                                                      :message => "created item #{item.name}"}))
      end
    else
      #display form with errors
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
    # Change attributes of the item.
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

    # Open the editing page with the existing attributes provided.
    @params[:name] = @item.name
    @params[:price] = @item.price
    @params[:about] = @item.about

    erb :edit_item
  end


  get "/item/:id" do
    redirect '/login' unless session[:user_id]

    @item = Item.by_id(params[:id].to_i)

    erb :item
  end

  get "/item/offer/:id" do
    redirect '/login' unless session[:user_id]

    @item = Item.offer_by_id(params[:id].to_i)

    erb :item, :locals => { :offer => true }
  end

  post "/item/:id/add_comment" do
    redirect '/login' unless session[:user_id]

    #input validation
    @errors[:comment] = "comment must not be empty" if params[:comment].empty?

    @item = Item.by_id(params[:id].to_i)

    if @errors.empty?
      @item.add_comment(Comment.init(:creator => @current_agent, :text => params[:comment]))

      # Add to activity list of the current agent
      @current_agent.add_activity(Activity.init({:creator => @current_agent,
                                                 :type => :comment,
                                                 :message => "commented on #{@item.name}"}))
      # If the user comments an item in the name of an organization, an organization activity is created.
      if @current_user != @current_agent
        @current_agent.add_orgactivity(Activity.init({:creator => @current_user,
                                                    :type => :comment,
                                                    :message => "commented on #{@item.name}"}))
      end

      redirect "/item/#{params[:id]}"
    else
      #display form with errors
      halt erb :item
    end
  end

  post "/item/:id/watchlist" do
    redirect '/login' unless session[:user_id]

    @item = Item.by_id(params[:id].to_i)
    # Puts to or removes item from wishlist of the current agent
    if @current_agent.wishlist.include?(@item)
      @current_agent.remove_item_from_wishlist(@item)
    else
      @current_agent.add_item_to_wishlist(@item)
    end

    redirect "/item/#{@item.id.to_s}"
  end

  post "/item/search" do
    redirect '/login' unless session[:user_id]

    # input validation
    halt erb :error, :locals => { :message => "search must not be empty" } if params[:search].empty?

    @found_items = Item.find_item(params[:search])
    @found_offers = Item.find_offer(params[:search])

    erb :searchresult
  end
