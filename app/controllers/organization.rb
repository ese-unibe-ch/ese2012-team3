# We define queries manipulating {Organization}s here.

# Some stuff we use often.
def before_get_org_by_id 
  @org = nil 
  
  if params.has_key?("id") && params[:id] &&  params[:id] != "create"
    halt erb :error, :locals => {:message => localized_message_single_key("NO_ORG_FOUND")} unless Organization.has_organization_with_id?(params[:id].to_i)
    @org = Organization.organization_by_id(params[:id].to_i)
  end
end

before "/organization/:id*" do
  before_get_org_by_id
end

ACCESSIBLE_ORG_OPTIONS = ["settings", "switch"] # Options accessible for normal members
# @current_user must be member and admin of that org to access any organization option pages
before "/organization/:id/:optn" do 
  before_get_org_by_id
  
  halt erb :error, :locals => {:message => localized_message_single_key("NOT_CURRENTLY_MEMBER")} unless @org.members.include?(@current_user)
  
  return if ACCESSIBLE_ORG_OPTIONS.include?(params[:optn])
  halt erb :error, :locals => {:message => localized_message_single_key("NO_ADMIN_RIGHTS")} unless @org.admins.include?(@current_user)
end

# ============ Accessible, public
get "/organization/create" do
  erb :create_organization
end

post "/organization/create" do

  name = params[:name]
  about = params[:about]
  # Input validation
  @errors[:name] = LocalizedMessage.new([LocalizedMessage::LangKey.new("ORG_MUST_HAVE_NAME")]) if name.empty?
  image_file_check()

  if !@errors.empty?
    halt erb :create_organization
  end
  # Create organization
  org = Organization.init(:name => name, :about => about, :admin => @current_user)
  org.image_file_name = add_image(ORGANIZATIONIMAGESROOT, org.id)
  flash[:success] = 'org_created'

  redirect back
end

get "/organization/:id" do
  erb :organization
end

# ============ Private for members only 
get "/organization/:id/switch" do
  # If the current_user is a member of the requested organization, the current_agent is set to the organization.
  session[:organization_id] = params[:id].to_i if Organization.organization_by_id(params[:id].to_i).has_member?(@current_user)
  flash[:success] = 'agent_switched'
  redirect back
end

# it would have been a better design to not include a parameter in all of the following:

get "/organization/:id/settings" do
  # Obviously, any user that is not already in the organization is eligible for membership.
  addable_users = User.all_outside_organization(@org)

  erb :organization_settings, :locals => {:addable_users   => addable_users}
end


# ============ Private for admins only
post "/organization/:id/add_member" do
  user_to_add = User.user_by_id(params[:user_to_add])
  halt erb :error, :locals => {:message => LocalizedMessage.new([LocalizedMessage::LangKey.new("NO_USER_TO_ADD_FOUND")])} unless user_to_add
  # Add user to org
  begin
    @org.add_member(user_to_add)
  rescue RuntimeError => e
    halt erb :error, :locals => {:message => e.message}
  end

  redirect "/organization/#{params[:id]}/settings"
end

post "/organization/:id/toggle_admin_member" do
  user_to_change = User.user_by_id(params[:user_to_change])
  halt erb :error, :locals => {:message => LocalizedMessage.new([LocalizedMessage::LangKey.new("NO_USER_TO_PROMOTE_FOUND")])} unless user_to_change
  
  # promote user
  begin
    @org.toggle_admin_rights(user_to_change)
  rescue RuntimeError => e
    halt erb :error, :locals => {:message => e.message}
  end

  redirect "/organization/#{params[:id]}/settings"
end

post "/organization/:id/remove_member" do
  #Remove user
  user_to_remove = User.user_by_id(params[:user_to_remove])
  @org.remove_member(user_to_remove)

  redirect back
end

post "/organization/:id/change_profile_picture" do
  set_error :image_file, LocalizedMessage.new([LocalizedMessage::LangKey.new("NO_FILE_CHOSEN")]) unless  params[:image_file]

  image_file_check()

  halt erb :settings unless @errors.empty?

  # Delete old picture if there is a new one
  if params[:image_file] != nil
    @org.delete_image_file
  end

  @org.image_file_name = add_image(ORGANIZATIONIMAGESROOT, @org.id)

  redirect "/organization/#{@org.id}"
end

delete "/organization/:id/delete_profile_picture" do
  halt erb :error, :locals =>
      {:message => LocalizedMessage.new([LocalizedMessage::LangKey.new("NO_PROFILE_PICTURE")])} unless @org.image_file_name

  @org.delete_image_file

  redirect "/organization/#{@org.id}"
end
