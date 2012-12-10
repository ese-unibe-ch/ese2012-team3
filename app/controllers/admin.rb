get "/admin" do
  admin!
  erb :"admin/index", :layout => :"admin/admin_layout"
end

get "/admin/delete_auction" do
  admin!
  @all_auctions = Market::Item.all_auctions
  erb :"admin/delete_auction", :layout => :"admin/admin_layout"
end

get "/admin/delete_item" do
  admin!
  @all_items = Market::Item.all
  erb :"admin/delete_item", :layout => :"admin/admin_layout"
end

get "/admin/delete_offer" do
  admin!
  @all_offers = Market::Item.all_offers
  erb :"admin/delete_offer", :layout => :"admin/admin_layout"
end

get "/admin/delete_user" do
  admin!
  @all_users = Market::User.all
  erb :"admin/delete_user", :layout => :"admin/admin_layout"
end

get "/admin/delete_org" do
  admin!
  @all_orgs = Market::Organization.all
  erb :"admin/delete_org", :layout => :"admin/admin_layout"
end

post "/item/delete" do
  admin!
  begin
    Market::Item.by_id(params[:id_to_delete].to_i).delete
  rescue Exception => e
     halt erb :"admin/admin_error", :locals => {:message => e.message}, :layout => :"admin/admin_layout"
  end
  redirect back
end

post "/user/delete" do
  admin!
  begin
    Market::User.user_by_id(params[:id_to_delete].to_i).delete
  rescue Exception => e
    halt erb :"admin/admin_error", :locals => {:message => e.message}, :layout => :"admin/admin_layout"
  end
  redirect back
end

post "/organization/delete" do
  admin!
  begin
    Market::Organization.organization_by_id(params[:id_to_delete].to_i).delete
  rescue Exception => e
    halt erb :"admin/admin_error", :locals => {:message => e.message}, :layout => :"admin/admin_layout"
  end
  redirect back
end

post "/auction/delete" do
  admin!
  # auction is removed if item is inactivated
  begin
    Market::Item.by_id(params[:id_to_delete].to_i).inactivate
  rescue Exception => e
    halt erb :"admin/admin_error", :locals => {:message => e.message}, :layout => :"admin/admin_layout"
  end
  redirect back
end

post "/offer/delete" do
  admin!
  # an offer is just an item in another list
  begin
    Market::Item.offer_by_id(params[:id_to_delete].to_i).delete
  rescue Exception => e
    halt erb :"admin/admin_error", :locals => {:message => e.message}, :layout => :"admin/admin_layout"
  end
  redirect back
end

# active user list

get "/admin/active_users" do
  admin!
   #return "Current time is "+Time.new.to_s

  erb :"admin/_active_users_list", :layout => false
end

# Localization
get "/admin/edit_localization" do
  admin!
  if !session[:admin_loc_language]
    session[:admin_loc_language] = DEFAULT_LANGUAGE
  end
  erb :"admin/edit_localization", :layout => :"admin/admin_layout"
end

post "/admin/edit_localization/set_language" do
  admin!
  session[:admin_loc_language] = params["language"]
  redirect back
end

post "/admin/edit_localization/submit" do
  admin!
  l = session[:admin_loc_language]
  params.each{|k,v|
     print "KEy #{k} and val #{v}\n"
     LANGUAGES[l].set k,v

  }
  redirect back
end
