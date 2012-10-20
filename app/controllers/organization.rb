
get "/organization/create" do
  redirect '/login' unless session[:user_id]
  erb :create_organization
end

post "/organization/create" do
  redirect '/login' unless session[:user_id]

  name = params[:name]
  about = params[:about]

  @errors[:name] = "organization must have a name!" if name.empty?
  image_file_check()

  if !@errors.empty?
    halt erb :create_organization
  end

  org = Organization.init(:name => name, :about => about, :admin => @current_login)
  org.image_file_name = add_image(ORGANIZATIONIMAGESROOT, org.id)

  redirect "/?orgcreated=true"
end

get "/organization/:id" do
  redirect '/login' unless session[:user_id]

  @org = Organization.organization_by_id(params[:id].to_i)
  halt erb :error, :locals => {:message => "no organization found to id #{params[:id]}"} unless @org

  @items = Item.items_by_agent(@org)
  addable_users = User.all.select {|u| !u.is_member_of?(@org)}

  erb :organization, :locals => {:addable_users   => addable_users}
end

post "/organization/:id/add_member" do
  redirect '/login' unless session[:user_id]

  @org = Organization.organization_by_id(params[:id].to_i)
  halt erb :error, :locals => {:message => "no organization found"} unless @org

  user_to_add = User.user_by_id(params[:user_to_add])
  halt erb :error, :locals => {:message => "no user found to add"} unless user_to_add

  begin
    @org.add_member(user_to_add)
  rescue RuntimeError => e
    halt erb :error, :locals => {:message => e.message}
  end

  redirect "/organization/#{params[:id]}"
end

post "/organization/:id/remove_member" do
  redirect '/login' unless session[:user_id]

  @org = Organization.organization_by_id(params[:id].to_i)
  halt erb :error, :locals => {:message => "no organization found"} unless @org

  user_to_remove = User.user_by_id(params[:user_to_remove])
  @org.remove_member(user_to_remove)

  return_to = params[:return_to] ? params[:return_to] : "/organization/#{params[:id]}"
  #redirect return_to
  redirect back
end


get "/organization/:id/switch" do
  redirect '/login' unless session[:user_id]
  session[:organization_id] = params[:id].to_i if Organization.organization_by_id(params[:id].to_i).has_member(@current_login)
  redirect "/?switcheduser=true"
end