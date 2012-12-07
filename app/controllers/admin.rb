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
  Market::Item.by_id(params[:id_to_delete].to_i).delete
  redirect back
end

post "/user/delete" do
  admin!
  Market::User.user_by_id(params[:id_to_delete].to_i).delete
  redirect back
end

post "/organization/delete" do
  admin!
  Market::Organization.organization_by_id(params[:id_to_delete].to_i).delete
  redirect back
end

post "/auction/delete" do
  admin!
  # auction is removed if item is inactivated
  Market::Item.by_id(params[:id_to_delete].to_i).inactivate
  redirect back
end

post "/offer/delete" do
  admin!
  # an offer is just an item in another list
  Market::Item.offer_by_id(params[:id_to_delete].to_i).delete
  redirect back
end
