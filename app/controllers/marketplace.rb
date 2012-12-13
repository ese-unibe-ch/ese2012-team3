# This defines all queries dealing with the main functionalities of the platform, that is buying and searching for items.

def get_item_by_id
  @item = Item.by_id(params[:id].to_i)
  @item = Item.offer_by_id(params[:id].to_i) unless @item
  halt erb :error, :locals => {:message => localized_message_single_key("NO_ITEMS_FOUND")} if @item.nil?
end

before "/item/:id*" do get_item_by_id end

def assert_owner
  halt erb :error, :locals => {:message => localized_message_single_key("ACCESS_DENIED")} if @current_agent != @item.owner # saying "access denied" is fine since these are not user errors, he just tried to hack our system.
end

def assert_normal
  halt erb :error, :locals => {:message => localized_message_single_key("ACCESS_DENIED")} if @item.is_offer? || @item.auction?
end

def assert_offer
  halt erb :error, :locals => {:message => localized_message_single_key("ACCESS_DENIED")} unless @item.is_offer?
end

def assert_auction
  halt erb :error, :locals => {:message => localized_message_single_key("CURRENTLY_NOT_IN_AUCTION")} unless @item.auction?
end

before "/item/:id/auction*" do 
  get_item_by_id
  assert_auction
end

# =============== Public

get "/item/offer" do
  erb :create_offer
end

get "/item/create" do
  erb :create_item
end


# Main item display page.
get "/item/:id" do
  erb :item
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

# @param is_offer true if to create offer
# @param halt_at view to open on failure
def item_create_common(is_offer, halt_at)
  #input validation
  check_item_params

  image_file_check()

  halt erb halt_at unless @errors.empty? #display form with errors
  
  #create item
  safe = is_offer ? Safe.new : nil
  safe.fill(@current_agent, 1) if is_offer # will be set to right value in set_from_params
  item = Market::Item.init(
                    :price  => 1,
                    :active => false,
                    :owner  => @current_agent,
                    :offer => is_offer,
                    :safe => safe)
  item.name = LocalizedLiteral.new({})   
  item.about = LocalizedLiteral.new({})         

  if !is_offer
    # If the user creates an item in the name of an organization, an organization activity is created.
    if @current_user != @current_agent
      @current_agent.add_orgactivity(Activity::new_createitem_activity(@current_user, item))
    end
  else
    Market::Item.add_offer(item) # offers must be added separately
  end
  
  set_item_values_from_params(item)

  redirect @current_agent.profile_route
end


post "/item/offer" do
  @errors[:price] = LocalizedMessage.new([LocalizedMessage::LangKey.new("PRICE_MUST_BE_LESS_CREDITS")]) unless params[:price].to_i <= @current_agent.credit
  item_create_common(true, :create_offer)
end



post "/item/create" do
  item_create_common(false, :create_item)
end

post "/item/:id/sell" do
  assert_offer
  
  # TODO move selling logic to model:
  Market::Item.transform_offer_to_item(@item)
  @current_agent.credit += @item.safe.savings
  
  redirect '/'
end

def set_item_values_from_params(item)
  item.price = params[:price].to_i
  # TODO move logic to model
  if item.is_offer?
    item.safe.return
    item.safe = Safe.new
    item.safe.fill(@current_agent, item.price)
  end

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

post "/item/:id/buy" do
  assert_normal
  begin
    @current_agent.buy_item(@item)
  rescue Exception => e
    halt erb :error, :locals => {:message => e.message}
  end
  # If the user buys an item in the name of an organization, an organization activity is created.
  if @current_user != @current_agent
    @current_agent.add_orgactivity(Activity::new_buy_activity(@current_user, @item))
  end

  session[:last_bought_item_id] = @item.id
  flash[:success] = 'item_bought'

  redirect back
end

post "/item/:id/watchlist" do
  # Puts to or removes item from wishlist of the current agent
  if @current_agent.wishlist.include?(@item)
    @current_agent.remove_item_from_wishlist(@item)
  else
    @current_agent.add_item_to_wishlist(@item)
  end

  redirect "/item/#{@item.id.to_s}"
end



post "/item/:id/add_comment" do

  #input validation
  @errors[:comment] = LocalizedMessage.new([LocalizedMessage::LangKey.new("COMMENT_MAY_NOT_BE_EMPTY")]) if params[:comment].empty?

  if @errors.empty?
    @item.add_comment(Comment.init(:creator => @current_agent, :text => params[:comment]))

    # Add to activity list of the current agent
    @current_agent.add_activity(Activity::new_comment_activity(@current_agent, @item))
    # If the user comments an item in the name of an organization, an organization activity is created.
    if @current_user != @current_agent
      @current_agent.add_orgactivity(Activity::new_comment_activity(@current_user, @item))
    end

    redirect "/item/#{params[:id]}"
  else
    #display form with errors
    halt erb :item
  end
end

post "/item/:id/bid" do
  assert_auction
  item =  @item
  agent = @current_agent
  price = params[:bid].to_i


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

get "/item/:id/auction" do
  item = @item

  if (item.auction.nil?)
    #make redirect with alert
    flash['error'] = 'no_auction'
    redirect '/'
  end

  params[:bid] = item.auction.minimal_bid
  erb :auction, :locals => { :item => item }
end

# =============== Private - current agent must be owner

post "/item/:id/status_change" do
  assert_owner

    #Changes the current status of the item,
    #irrelevant of what it is.
    @item.change_status


    #add to activity list of the agent if item was activated
  if @item.active == true
    @current_agent.add_activity(Activity::new_activate_activity(@current_agent, @item))
    # If the user activates an item in the name of an organization, an organization activity is created.
    if @current_user != @current_agent
      @current_agent.add_orgactivity(Activity::new_activate_activity(@current_user, @item))
    end
  end
  redirect back
end

post "/item/:id/edit" do
  assert_owner
  
  #input validation
  check_item_params
  image_file_check()

  # Change attributes of the item.
  halt erb :edit_item unless @errors.empty?

  set_item_values_from_params(@item)
  redirect @current_agent.profile_route
end

get "/item/:id/edit" do
  assert_owner
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

# ************* Private, auction related
get "/item/:id/auction/create" do
  assert_owner
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
  assert_owner
  
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

get "/item/:id/auction/edit" do
  assert_owner

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
  assert_owner
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



# =============== Searching
require "cgi"

# dummy. Getting /search does nothing, you search from the main page (or any page)
get "/search" do
  redirect "/"
end

post "/search" do
  redirect '/login' unless session[:user_id]

  # input validation
  halt erb :error, :locals => { :message => LocalizedMessage.new([LocalizedMessage::LangKey.new("SEARCH_MAY_NOT_BE_EMPTY")]) } if params[:search].empty?
  search_query = params[:search]

  redirect "/search/#{CGI::escape(search_query)}"
end

get "/search/:search_query" do
  params[:search_query] = CGI::unescape(params[:search_query])
  @found_items = Item.find_item(params[:search_query].downcase)
  @found_offers = Item.find_offer(params[:search_query].downcase)

  erb :searchresult
end
