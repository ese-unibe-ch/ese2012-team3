
get "/organization/create" do
  redirect '/login' unless session[:user_id]
  erb :create_organization
end

post "/organization/create" do
  redirect '/login' unless session[:user_id]

  name = params[:name]
  about = params[:about]
  # Input validation
  @errors[:name] = "organization must have a name!" if name.empty?
  image_file_check()

  if !@errors.empty?
    halt erb :create_organization
  end
  # Create organization
  org = Organization.init(:name => name, :about => about, :admin => @current_user)
  org.image_file_name = add_image(ORGANIZATIONIMAGESROOT, org.id)

  redirect "/?alert=orgcreated"
end

get "/organization/:id" do
  redirect '/login' unless session[:user_id]

  @org = Organization.organization_by_id(params[:id].to_i)
  halt erb :error, :locals => {:message => "no organization found to id #{params[:id]}"} unless @org
  # Provide item list of the organization
  @items = Item.items_by_agent(@org)

  erb :organization
end

post "/organization/:id/add_member" do
  redirect '/login' unless session[:user_id]
  # Check for valid IDs
  @org = Organization.organization_by_id(params[:id].to_i)
  halt erb :error, :locals => {:message => "no organization found"} unless @org

  user_to_add = User.user_by_id(params[:user_to_add])
  halt erb :error, :locals => {:message => "no user found to add"} unless user_to_add
  # Add user to org
  begin
    @org.add_member(user_to_add)
  rescue RuntimeError => e
    halt erb :error, :locals => {:message => e.message}
  end

  redirect "/organization/#{params[:id]}/settings"
end

post "/organization/:id/remove_member" do
  redirect '/login' unless session[:user_id]
  # Check for valid ID
  @org = Organization.organization_by_id(params[:id].to_i)
  halt erb :error, :locals => {:message => "no organization found"} unless @org
  #Remove user
  user_to_remove = User.user_by_id(params[:user_to_remove])
  @org.remove_member(user_to_remove)

  redirect back
end


get "/organization/:id/switch" do
  redirect '/login' unless session[:user_id]
  # If the current_user is a member of the requested organization, the current_agent is set to the organization.
  session[:organization_id] = params[:id].to_i if Organization.organization_by_id(params[:id].to_i).has_member?(@current_user)
  redirect "/?alert=switcheduser"
end

get "/organization/:id/settings" do
  redirect '/login' unless session[:user_id]

  @org = Organization.organization_by_id(params[:id].to_i) 
  halt erb :error, :locals => {:message => "no organization found to id #{params[:id]}"} unless @org
  # Obviously, any user that is not already in the organization is eligible for membership.
  addable_users = User.all.select {|u| !u.is_member_of?(@org)}

  erb :organization_settings, :locals => {:addable_users   => addable_users}
end

post "/change_profile_picture_organization" do
  set_error :image_file, "You didn't choose a file" unless  params[:image_file]

  image_file_check()

  halt erb :settings unless @errors.empty?

  org = @current_agent
  # Delete old picture if there is a new one
  if org.image_file_name != nil && params[:image_file] != nil
    org.delete_profile_picture_organization
  end

  org.image_file_name = add_image(ORGANIZATIONIMAGESROOT, org.id)

  redirect "/organization/#{org.id}"
end

delete "/delete_profile_picture_organization" do
  org = @current_agent

  halt erb :error, :locals =>
      {:message => "You don't have a profile picture"} unless org.image_file_name

  org.delete_image_file

  redirect "/organization/#{org.id}"
end
