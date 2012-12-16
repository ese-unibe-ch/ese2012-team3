# We define queries manipulating {User Users} here.

get "/settings" do
  erb :settings
end

before "/profile/:id" do
  halt erb :error, :locals => {:message => localized_message_single_key("NO_USER_FOUND")} unless User.has_user_with_id?(params[:id].to_i)
  @user = User.user_by_id(params[:id])
end

get "/profile/:id" do
  erb :userprofile
end

# it would have been a better design to not include a parameter
delete "/profile/:id" do
  halt erb :error, :locals => {:message => localized_message_single_key("ACCESS_DENIED")} unless @user == @current_user
  @user.delete
  redirect "/logout"
end

get "/delete_confirmation" do
  erb :delete_confirmation
end

get "/user/switch" do
  # Remove the organization id from the session, the current_agent will be set back to current_user
  session[:organization_id] = nil
  flash[:success] = 'agent_switched'
  redirect back
end

# sets the error codes if the password and confirmation given in params (<tt>params[:passwordc], params[:passwordc]</tt>) are invalid
def passwordcheck()
  set_error :password, localized_message_single_key("NO_PASSWORD_GIVEN") unless params[:password] && params[:password].size > 0
  set_error :passwordc, localized_message_single_key("NO_PASSWORD_CONFIRM_GIVEN") unless params[:password] && params[:password].size > 0
  set_error :passwordc, localized_message_single_key("PASS_AND_RETYPED_PASS_DONT_MATCH") unless params[:passwordc] == params[:password]

  begin
    PasswordCheck::ensure_password_strong(params[:password], params[:name], params[:currentpassword])
  rescue => e
    set_error :password, e #.message
  end
end

# Losing the image selected when you did a mistake is annoying, but there's nothing we can do, you can't specify a default value for 
# file selection controls for security reasons.
post "/register" do
  redirect '/' if session[:user_id]

  image_file_check()

  # ======================= Error handling... basically copy of what exceptions already do, but with categorizing
  # TODO think of better way - we could move all exception throwing to the model just like ensure_password_strong does, but it's a lot of effort to change this now
  set_error :name, localized_message_single_key("NO_USERNAME_GIVEN") unless params[:name] && params[:name].size > 0
  set_error :name, localized_message_single_key("USERNAME_EXISTS") if Market::User.user_by_name(params[:name])

  passwordcheck()

  print @errors
  halt erb :register unless @errors.empty?

  user = User.init(:name => params[:name], :credit => DEFAULT_CREDITS,
                   :password => params[:password], :about => params[:about])
  user.image_file_name = add_image(USERIMAGESROOT, user.id,params[:image_file])

  session[:user_id] = user.id
  flash[:success] = 'registered'
  redirect '/'
end

get "/register" do
  redirect '/' if session[:user_id]

  erb :register
end

post "/change_password" do

  set_error :currentpassword, localized_message_single_key("CURRENT_PASS_WRONG") unless @current_user.password == params[:currentpassword]

  params[:name] = @current_user.name
  passwordcheck()

  halt erb :settings unless @errors.empty?

  @current_user.password = params[:password]
  flash[:success] = 'password_changed'
  redirect "/settings" # cannot redirect back since we might come from /change_password which is not really a page
end

post "/change_profile_picture" do

  set_error :image_file, localized_message_single_key("NO_FILE_CHOSEN") unless  params[:image_file]

  image_file_check()

  if !@errors.empty?
    response['Content-Location'] = "/settings" # doesn't seem to work.
    halt erb :settings
  end

  @current_user = @current_user
  if @current_user.image_file_name != nil && params[:image_file] != nil
    @current_user.delete_image_file
  end

  @current_user.image_file_name = add_image(USERIMAGESROOT, @current_user.id,params[:image_file])

  redirect "/settings"
end

delete "/delete_profile_picture" do
  halt erb :error, :locals =>
      {:message => localized_message_single_key("NO_PROFILE_PICTURE")} unless @current_user.image_file_name

  @current_user.delete_image_file

  redirect back
end

post "/follow" do

  # There is a form param :agent which either says @current_user or organization.
  # This is necessary because they have separate IDs.
  if params[:agent] == "user"
    follow = User.user_by_id(params[:follow_id].to_i)
  else
    follow = Organization.organization_by_id(params[:follow_id].to_i)
  end

  #add to activity list
  @current_agent.add_activity(Activity::new_follow_activity(@current_agent, follow))

  # remove from/add to following list
  @current_user.follow(follow)

  redirect back
end
