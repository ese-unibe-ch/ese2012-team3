# The queries defined here deal with the admin page, acessible under /admin.

# Must be logged in as admin for all admin pages
before "/admin*" do 
  admin!
end

get "/admin" do
  erb :"admin/index", :layout => :"admin/admin_layout"
end

get "/admin/delete_auction" do  
  @all_auctions = Market::Item.all_auctions
  erb :"admin/delete_auction", :layout => :"admin/admin_layout"
end

get "/admin/delete_item" do
  @all_items = Market::Item.all
  erb :"admin/delete_item", :layout => :"admin/admin_layout"
end

get "/admin/delete_offer" do
  @all_offers = Market::Item.all_offers
  erb :"admin/delete_offer", :layout => :"admin/admin_layout"
end

get "/admin/delete_user" do
  @all_users = Market::User.all
  erb :"admin/delete_user", :layout => :"admin/admin_layout"
end

get "/admin/delete_org" do
  @all_orgs = Market::Organization.all
  erb :"admin/delete_org", :layout => :"admin/admin_layout"
end

post "/admin/item/delete" do
  admin!
  begin
    Market::Item.by_id(params[:id_to_delete].to_i).delete
  rescue Exception => e
     halt erb :"admin/admin_error", :locals => {:message => e.message}, :layout => :"admin/admin_layout"
  end
  redirect back
end

post "/admin/user/delete" do
  admin!
  begin
    Market::User.user_by_id(params[:id_to_delete].to_i).delete
  rescue Exception => e
    halt erb :"admin/admin_error", :locals => {:message => e.message}, :layout => :"admin/admin_layout"
  end
  redirect back
end

post "/admin/organization/delete" do
  admin!
  begin
    Market::Organization.organization_by_id(params[:id_to_delete].to_i).delete
  rescue Exception => e
    halt erb :"admin/admin_error", :locals => {:message => e.message}, :layout => :"admin/admin_layout"
  end
  redirect back
end

post "/admin/auction/delete" do
  # auction is removed if item is inactivated
  begin
    Market::Item.by_id(params[:id_to_delete].to_i).change_status
  rescue Exception => e
    halt erb :"admin/admin_error", :locals => {:message => e.message}, :layout => :"admin/admin_layout"
  end
  redirect back
end

post "/admin/offer/delete" do
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
   #return "Current time is "+Time.new.to_s

  erb :"admin/_active_users_list", :layout => false
end

# Localization
get "/admin/edit_localization" do
  if !session[:admin_loc_language]
    session[:admin_loc_language] = DEFAULT_LANGUAGE
  end
  erb :"admin/edit_localization", :layout => :"admin/admin_layout"
end

post "/admin/edit_localization/set_language" do
  session[:admin_loc_language] = params["language"]
  redirect back
end

post "/admin/edit_localization/submit" do
  l = session[:admin_loc_language]
  params.each{|k,v|
     #print "KEy #{k} and val #{v}\n"
     LANGUAGES[l].set k,v

  }
  redirect back
end
