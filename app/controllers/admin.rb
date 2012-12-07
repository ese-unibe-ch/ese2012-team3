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
