# This file defines queries accessible to all visitors, whether logged in or not.
# We also define some controller-level global functionality here, such as the preparation for all queries.

# Global before handler
# Sets up variables for later use, most importantly current_user which stores the user that is currently logged in and current_agent which is either
# equal to current_user or is an organization. It represents the acting agent. Actions like buying items, editing etc. can either be done for the user
#himself (current_user == current_agent) or for the organization he's working for (current_user != current_agent).
# @internal_note Reference for before: http://stackoverflow.com/questions/7703962/in-sinatra-how-do-you-make-a-before-filter-that-match-all-routes-except-some
before do
  # Clear if invalid
  if session[:user_id] and !User.has_user_with_id?(session[:user_id])
    session[:user_id] = nil
  end

  if (session[:organization_id] and !Organization.has_organization_with_id?(session[:organization_id].to_i)) or session[:user_id] == nil # cannot stay logged in as org if there's no backing user
    session[:organization_id] = nil
  end

  @current_id = session[:user_id]

  # The user that is currently logged in in this session
  @current_user = session[:user_id] ? Market::User.user_by_id(session[:user_id]) : nil
  if @current_user && !request.path_info.include?(".") # if the user is logged in and requested a page (not a file),
    @current_user.logged_in = true # ensure is set
    @current_user.last_action_time = Time.new
    @current_user.last_action_url  = request.path_info
  end

  # The user/agent we are working for (buying items)
  if session[:organization_id].nil?
    @current_agent = session[:user_id] ? Market::User.user_by_id(session[:user_id]) : nil
  else
    @current_agent = Organization.organization_by_id(session[:organization_id].to_i)
  end
  @all_items = Market::Item.active_items
  @all_offers = Market::Item.all_offers
  @users = Market::User.all + Market::Organization.all
  @errors = {}

  # Language
  if session[:language].nil? or !LANGUAGES.has_key?(session[:language])
    session[:language] = DEFAULT_LANGUAGE # reset to default if invalid
  end
  @current_language = LANGUAGES[session[:language]]
  @LANG = @current_language # SHORTCUT
  @LANGCODE = session[:language] # de, jp, en, fr, equivalent to @LANG["LANGUAGE_CODE"]
end

PUBLIC_ROUTES = ["/strongpass", "/login", "/error", "/register"]

# ensure login
before do
  return if request.path_info.include?(".") # files are ok
  return if PUBLIC_ROUTES.include?(request.path_info)
  return if request.path_info.include?("/set_language/")
  return if request.path_info.include?("/admin")
  ensure_logged_in!
end



#get "public/:fname" do # see _image_rect.erb
 # send_file("#{PUBLIC_FOLDER}/"+params[:fname])
#end

not_found do
  halt erb :error, :locals => {:message => localized_message_single_key("PAGE_NOT_FOUND")}
end

get "/strongpass" do
  erb :strongpass
end

get "/all_users" do
  erb :userlist
end

get "/error" do
  erb :error
end

get "/settings" do
  # Show user settings if logged in as a user, show org settings otherwise.
  if @current_user == @current_agent
    erb :settings
  else
    # Obviously, any user that is not already in the organization is eligible for membership.
    addable_users = User.all_outside_organization(@current_agent)
    @org = @current_agent
    erb :organization_settings, :locals => {:addable_users   => addable_users}
  end
end

post "/set_activity_filter" do
  session[:activity_filter] = []
  session[:activity_filter] << "comment"    if params[:comment]
  session[:activity_filter] << "follow"     if params[:follow]
  session[:activity_filter] << "activate"   if params[:activate]
  session[:activity_filter] << "buy"        if params[:buy]
  session[:activity_filter] << "createitem" if params[:createitem]

  redirect back
end

get "/set_language/:lang" do
  session[:language] = params[:lang]
  redirect back
end

# Marketplace main page
get "/" do
  activities = @current_agent.get_followees_activities;
  erb :marketplace, :locals => {:activity_list => activities}
end

