
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
  session[:organization_id] = nil
  redirect back + "?alert=switcheduser"
end

def passwordcheck()
  set_error :password, "No password given" unless params[:password] && params[:password].size > 0
  set_error :passwordc, "No password confirmation given" unless params[:password] && params[:password].size > 0
  set_error :passwordc, "Password and retyped password don't match" unless params[:passwordc] == params[:password]

  begin
    PasswordCheck::ensure_password_strong(params[:password], params[:name], params[:currentpassword])
  rescue => e
    set_error :password, e.message
  end
end

# Do we really want inline errors with this?
# Losing the image one selected is annoying..
post "/register" do
  redirect '/' if session[:user_id]

  image_file_check()

  # ======================= Error handling... basically copy of what exceptions already do, but with categorizing
  # TODO think of better way
  set_error :name, "No username given" unless params[:name] && params[:name].size > 0
  set_error :name, "User with given username already exists" if Market::User.user_by_name(params[:name])

  passwordcheck()

  print @errors
  halt erb :register unless @errors.empty?

  user = User.init(:name => params[:name], :credit => DEFAULT_CREDITS,
                   :password => params[:password], :about => params[:about])
  user.image_file_name = add_image(USERIMAGESROOT, user.id)

  session[:user_id] = user.id
  redirect "/?alert=registered"
end

get "/register" do
  redirect '/' if session[:user_id]

  erb :register
end

post "/change_password" do
  redirect '/' if !session[:user_id]

  set_error :currentpassword, "Current password is wrong" unless @current_login.password == params[:currentpassword]

  params[:name] = @current_login.name
  passwordcheck()

  halt erb :settings unless @errors.empty?

  @current_login.password = params[:password]

  redirect "/?alert=pwchanged"
end

post "/change_profile_picture" do
  set_error :image_file, "You didn't choose a file" unless  params[:image_file]

  image_file_check()

  halt erb :settings unless @errors.empty?

  user = @current_login
  if user.image_file_name != nil && params[:image_file] != nil
    user.delete_profile_picture
  end

  user.image_file_name = add_image(USERIMAGESROOT, user.id)

  redirect "/profile/#{user.id}"
end

delete "/delete_profile_picture" do
  user = @current_login

  halt erb :error, :locals =>
      {:message => "You don't have a profile picture"} unless user.image_file_name

  @current_login.delete_image_file

  redirect "/profile/#{user.id}"
end


post "/follow" do
  redirect '/login' unless session[:user_id]
  @current_login.follow(User.user_by_id(params[:follow_id].to_i)) if params[:agent] == "user"
  @current_login.follow(Organization.organization_by_id(params[:follow_id].to_i)) if params[:agent] == "org"
  redirect back
end
