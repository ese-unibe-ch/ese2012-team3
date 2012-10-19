
get "/settings" do
  redirect '/login' unless session[:user_id]
  erb :settings
end

get "/profile/:id" do
  redirect '/login' unless session[:user_id]

  @user = User.user_by_id(params[:id])

  @items = Item.items_by_agent(@user)
  @organizations = Organization.organizations_by_user(@user)

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
  redirect "/?switcheduser=true"
end

def passwordcheck(password, passwordc, username, oldpass)

  halt erb :error, :locals =>
      {:message => "No password given"} unless password
  halt erb :error, :locals =>
      {:message => "Password and retyped password don't match"} unless passwordc == password

  begin
    PasswordCheck::ensure_password_strong(password, username, oldpass)
  rescue => e
    halt erb :error, :locals =>
        {:message => e.message}
  end
end



# Do we really want inline errors with this?
# Losing the image one selected is annoying..
post "/register" do
  redirect '/' if session[:user_id]

  username = params[:username]
  password = params[:password]
  passwordc = params[:passwordc]
  about = params[:about]
  file = params[:image_file]

  if file
    set_error :image_file,
                   "Image file too large, must be < #{MAXIMAGEFILESIZE/1024} kB,
                      is #{file[:tempfile].size/1024} kB" if file[:tempfile].size > MAXIMAGEFILESIZE
  end

  # ======================= Error handling... basically copy of what exceptions already do, but with categorizing
  # TODO think of better way
  set_error :name, "No username given" unless username && username.size > 0
  set_error :name, "User with given username already exists" if Market::User.user_by_name(params[:name])

  set_error :pwinput, "No password given" unless password && password.size > 0
  set_error :pwcinput, "No password confirmation given" unless password && password.size > 0
  set_error :pwcinput, "Password and retyped password don't match" unless passwordc == password

  begin
    PasswordCheck::ensure_password_strong(password, username, "")
  rescue => e
    set_error :pwinput, e.message
  end

  if !@errors.empty?
    halt erb :register, :locals => {:user_name => username || '',
                                    :about     => about || ''}
  end

  user = User.init(:name => username, :credit => 200,
                   :password => password, :about => params[:about])

  file = params[:image_file]

  if file
    user.image_file_name = "#{user.id}"+"_"+(file[:filename])
    FileUtils::cp(file[:tempfile].path, File.join(File.dirname(__FILE__),"../public/userimages", user.image_file_name) )
  end

  session[:user_id] = user.id
  redirect "/?registered=true"
end

# TODO move
get "public/userimages/:userimgfname" do # we could also just make them request the right file
  send_file(File.join(File.dirname(__FILE__),"../public/userimages", params[:userimgfname]))
end

get "/register" do
  redirect '/' if session[:user_id]

  erb :register, :locals => {:user_name => '',
                             :about => ''}
end

post "/change_password" do
  user = Market::User.user_by_id(session[:user_id])

  #halt erb :error, :locals =>
  #    {:message => "N"} unless @current_user

  password = params[:password]
  passwordc = params[:passwordc]
  currentpassword = params[:currentpassword]

  halt erb :error, :locals =>
      {:message => "Current password is wrong"} unless @current_user.password == currentpassword

  passwordcheck(password, passwordc, user.name, currentpassword)
  user.password = password

  redirect "/?pwchanged=true"
end

post "/change_profile_picture" do
  file = params[:image_file]
  user = @current_login
  if user.image_file_name != nil && file != nil
    user.delete_profile_picture
  end

  halt erb :error, :locals =>
      {:message => "You didn't chose a file"} until file != nil

  if file
    set_error :image_file,
                   "Image file too large, must be < #{MAXIMAGEFILESIZE/1024} kB,
                      is #{file[:tempfile].size/1024} kB" if file[:tempfile].size > MAXIMAGEFILESIZE
  end

  file = params[:image_file]

  if file
    user.image_file_name = "#{user.id}"+"_"+(file[:filename])
    FileUtils::cp(file[:tempfile].path, File.join(File.dirname(__FILE__),"../public/userimages", user.image_file_name) )
  end

  redirect "/profile/#{user.id}"
end

delete "/delete_profile_picture" do
  user = @current_login
  file = user.image_file_name
  user.delete_profile_picture

  halt erb :error, :locals =>
      {:message => "You don't have a profile picture"} until file != nil

  redirect "/profile/#{user.id}"
end