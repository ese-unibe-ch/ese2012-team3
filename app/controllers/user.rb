
get "/settings" do
  redirect '/login' unless session[:user_id]
  erb :settings
end

get "/profile/:id" do
  redirect '/login' unless session[:user_id]

  @user = User.user_by_id(params[:id])

  erb :userprofile
end

delete "/profile/:id" do
  redirect '/login' unless session[:user_id]

  @user = Market::User.user_by_id(params[:id]).delete

  redirect "/logout"
end

get "/delete_confirmation" do
  erb :delete_confirmation
end


get "/user/switch" do
  redirect '/login' unless session[:user_id]
  # Remove the organization id from the session, the current_agent will be set back to current_user
  session[:organization_id] = nil
  flash[:success] = 'agent_switched'
  redirect back
end

# sets the error codes if the password and confirmation given in params (<tt>params[:passwordc], params[:passwordc]</tt>) are invalid
def passwordcheck()
  set_error :password, LocalizedMessage.new([LocalizedMessage::LangKey.new("NO_PASSWORD_GIVEN")]) unless params[:password] && params[:password].size > 0
  set_error :passwordc, LocalizedMessage.new([LocalizedMessage::LangKey.new("NO_PASSWORD_CONFIRM_GIVEN")]) unless params[:password] && params[:password].size > 0
  set_error :passwordc, LocalizedMessage.new([LocalizedMessage::LangKey.new("PASS_AND_RETYPED_PASS_DONT_MATCH")]) unless params[:passwordc] == params[:password]

  begin
    PasswordCheck::ensure_password_strong(params[:password], params[:name], params[:currentpassword])
  rescue => e
    set_error :password, e #.message
  end
end

# Do we really want inline errors with this?
# Losing the image one selected is annoying..
post "/register" do
  redirect '/' if session[:user_id]

  image_file_check()

  # ======================= Error handling... basically copy of what exceptions already do, but with categorizing
  # TODO think of better way
  set_error :name, LocalizedMessage.new([LocalizedMessage::LangKey.new("NO_USERNAME_GIVEN")]) unless params[:name] && params[:name].size > 0
  set_error :name, LocalizedMessage.new([LocalizedMessage::LangKey.new("USERNAME_EXISTS")]) if Market::User.user_by_name(params[:name])

  passwordcheck()

  print @errors
  halt erb :register unless @errors.empty?

  user = User.init(:name => params[:name], :credit => DEFAULT_CREDITS,
                   :password => params[:password], :about => params[:about])
  user.image_file_name = add_image(USERIMAGESROOT, user.id)

  session[:user_id] = user.id
  flash[:success] = 'registered'
  redirect '/'
end

get "/register" do
  redirect '/' if session[:user_id]

  erb :register
end

post "/change_password" do
  redirect '/' if !session[:user_id]

  set_error :currentpassword, LocalizedMessage.new([LocalizedMessage::LangKey.new("CURRENT_PASS_WRONG")]) unless @current_user.password == params[:currentpassword]

  params[:name] = @current_user.name
  passwordcheck()

  halt erb :settings unless @errors.empty?

  @current_user.password = params[:password]
  flash[:success] = 'password_changed'
  redirect back
end

post "/change_profile_picture" do
  set_error :image_file, LocalizedMessage.new([LocalizedMessage::LangKey.new("NO_FILE_CHOSEN")]) unless  params[:image_file]

  image_file_check()

  halt erb :settings unless @errors.empty?

  user = @current_user
  if user.image_file_name != nil && params[:image_file] != nil
    user.delete_profile_picture
  end

  user.image_file_name = add_image(USERIMAGESROOT, user.id)

  redirect "/profile/#{user.id}"
end

delete "/delete_profile_picture" do
  user = @current_user

  halt erb :error, :locals =>
      {:message => LocalizedMessage.new([LocalizedMessage::LangKey.new("NO_PROFILE_PICTURE")])} unless user.image_file_name

  @current_user.delete_image_file

  redirect "/profile/#{user.id}"
end


post "/follow" do
  redirect '/login' unless session[:user_id]

  # There is a form param :agent which either says user or organization.
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
