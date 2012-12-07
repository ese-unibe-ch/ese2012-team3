
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
      @current_agent.add_orgactivity(new_buy_activity(@current_user, @item))
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

  def check_auction_errors(end_time)
    @errors[:increment] =     LocalizedMessage.new([LocalizedMessage::LangKey.new("INCREMENT_MUST_SET")]) if params[:increment].empty?
    @errors[:end_time] =      LocalizedMessage.new([LocalizedMessage::LangKey.new("END_TIME_MUST_SET")]) if params[:end_time].empty?
    @errors[:minimal_price] = LocalizedMessage.new([LocalizedMessage::LangKey.new("MINPRICE_MUST_SET")]) if params[:minimal_price].empty?
    @errors[:increment] = LocalizedMessage.new([LocalizedMessage::LangKey.new("INCREMENT_POSITIVE_INT")]) unless params[:increment] =~ /^[0-9]+$/
    @errors[:increment] = LocalizedMessage.new([LocalizedMessage::LangKey.new("INCREMENT_GT_0")]) if params[:increment] <= "0"
    @errors[:minimal_price] = LocalizedMessage.new([LocalizedMessage::LangKey.new("MINPRICE_POSITIVE_INT")]) unless params[:minimal_price] =~ /^[0-9]+$/
    if end_time then
      @errors[:end_time] = LocalizedMessage.new([LocalizedMessage::LangKey.new("TIME_MUST_FUTURE")]) unless end_time > Time.now
    end



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
    begin
      end_time = paramToTime(params[:end_time])
    rescue
      @errors[:end_time] = LocalizedMessage.new([LocalizedMessage::LangKey.new("TIME_INVALID")])
    end


    #Input validation
    check_auction_errors(end_time)

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

    @errors[:bid] = LocalizedMessage.new([LocalizedMessage::LangKey.new("BID_GIVEN_CHOOSE_HIGHER")]) if item.auction.already_bid?(price.to_i)
    @errors[:bid] = LocalizedMessage.new([LocalizedMessage::LangKey.new("BID_MUST_BE_AT_LEAST")]) if !item.auction.valid_bid?(price.to_i)
    @errors[:bid] = LocalizedMessage.new([LocalizedMessage::LangKey.new("NOT_ENOUGH_MONEY")]) if price > agent.credit

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
    params[:end_time] = @item.auction.end_time.strftime(@LANG["LOCAL_DATE_TIME_FORMAT"])
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
    begin
      end_time = paramToTime(params[:end_time])
    rescue
      @errors[:end_time] = LocalizedMessage.new([LocalizedMessage::LangKey.new("TIME_INVALID")])
    end

    #Input validation  (same as in create)
    check_auction_errors(end_time)


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
        @current_agent.add_activity(new_activate_activity(@current_agent, @item))
        # If the user activates an item in the name of an organization, an organization activity is created.
        if @current_user != @current_agent
          @current_agent.add_orgactivity(new_activate_activity(@current_user, @item))
        end

      end
    end

    redirect back
  end

  get "/item/offer" do
    redirect '/login' unless session[:user_id]
    erb :create_offer
  end


  def check_item_params
    i = 0
    while params.has_key?("language_#{i}")
      @errors["name_#{i}"]  = LocalizedMessage.new([LocalizedMessage::LangKey.new("ITEM_MUST_HAVE_NAME")]) if !params["name_#{i}"] || params["name_#{i}"].empty?
      i+=1
    end

    @errors[:price] = LocalizedMessage.new([LocalizedMessage::LangKey.new("ITEM_MUST_HAVE_PRICE")]) if !params[:price] || params[:price].empty?
    @errors[:price] = LocalizedMessage.new([LocalizedMessage::LangKey.new("PRICE_MUST_BE_POSITIVE")]) unless params[:price].to_i > 0
    @errors[:price] = LocalizedMessage.new([LocalizedMessage::LangKey.new("PRICE_MUST_BE_INTEGER")]) unless params[:price].match /^[0-9]*$/
  end

  post "/item/offer" do
    redirect '/login' unless session[:user_id]

    #input validation
    check_item_params
    @errors[:price] = LocalizedMessage.new([LocalizedMessage::LangKey.new("PRICE_MUST_BE_LESS_CREDITS")]) unless params[:price].to_i <= @current_agent.credit

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


  def set_item_values_from_params(item)
    item.price = params[:price].to_i

    i = 0
    while params.has_key?("language_#{i}")
      print "Language #{i} is set to "+params["language_#{i}"]+"\n"
      item.name.set  params["language_#{i}"], params["name_#{i}"]
      item.about.set params["language_#{i}"], params["about_#{i}"]
      i+=1
    end

    if params[:image_file]
      item.delete_image_file
      item.image_file_name = add_image(ITEMIMAGESROOT, item.id)
    end
  end


  post "/item/create" do

    redirect '/login' unless session[:user_id]

    #input validation
    check_item_params

    image_file_check()

    #create item
    if @errors.empty?
      item = Market::Item.init(
                        :name   => "",
                        :price  => 1,
                        :active => false,
                        :owner  => @current_agent,
                        :about => "")

      set_item_values_from_params(item)

      # If the user creates an item in the name of an organization, an organization activity is created.
      if @current_user != @current_agent
        @current_agent.add_orgactivity(new_createitem_activity(@current_user, item))
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
    check_item_params
    image_file_check()

    # Change attributes of the item.
    if @errors.empty?

      set_item_values_from_params(@item)
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
    i = 0
    LANGUAGES.each{| key, value |
       if @item.name.defined_for_langcode?(key)
         params["language_#{i}"] = key
         params["name_#{i}"] = @item.name[key]
         if @item.about.defined_for_langcode?(key)
           params["about_#{i}"] = @item.about[key]
         end
         i+=1
       end
    }

    params[:price] = @item.price


    params[:about] = @item.about

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
    @errors[:comment] = LocalizedMessage.new([LocalizedMessage::LangKey.new("COMMENT_MAY_NOT_BE_EMPTY")]) if params[:comment].empty?

    @item = Item.by_id(params[:id].to_i)

    if @errors.empty?
      @item.add_comment(Comment.init(:creator => @current_agent, :text => params[:comment]))

      # Add to activity list of the current agent
      @current_agent.add_activity(new_comment_activity(@current_agent, @item))
      # If the user comments an item in the name of an organization, an organization activity is created.
      if @current_user != @current_agent
        @current_agent.add_orgactivity(new_comment_activity(@current_user, @item))
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
    halt erb :error, :locals => { :message => LocalizedMessage.new([LocalizedMessage::LangKey.new("SEARCH_MAY_NOT_BE_EMPTY")]) } if params[:search].empty?

    @found_items = Item.find_item(params[:search])
    @found_offers = Item.find_offer(params[:search])

    erb :searchresult
  end
