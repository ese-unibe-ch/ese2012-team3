

  before do
    print request.path_info+"\n" # TODO Output redirect to login if not already requested right here for non auth. users so we don't have to chack later
    # Problem: We don't want to redirect ordinary files...

    # Clear if invalid
    if session[:user_id] and !User.has_user_with_id?(session[:user_id])
      session[:user_id] = nil
    end

    if session[:organization_id] and !Organization.has_organization_with_id?(session[:organization_id].to_i)
      session[:organization_id] = nil
    end

    @current_id = session[:user_id]

    # The user that is currently logged in in this session
    @current_user = session[:user_id] ? Market::User.user_by_id(session[:user_id]) : nil

    # The user/agent we are working for (buying items)
    if session[:organization_id].nil?
      @current_agent = session[:user_id] ? Market::User.user_by_id(session[:user_id]) : nil
    else
      @current_agent = Organization.organization_by_id(session[:organization_id].to_i)
    end
    @all_items = Market::Item.active_items
    @users = Market::User.all + Market::Organization.all
    @errors = {}
  end

  def set_error(at, text)
    @errors[at] = text
  end

  # Returns filename (relative to public) of the image added or nil if image is not present.
  # Expects image file to be in params[:image_file]
  def add_image(rootdir, id)
    file = params[:image_file]
    return nil unless file
    fn = rootdir+"/#{id}"+File.extname(file[:filename])
    FileUtils::cp(file[:tempfile].path, "#{PUBLIC_FOLDER}/"+fn)
    return fn
  end

  # sets the :image_file error if there's something wrong with the image provided
  def image_file_check
    file = params[:image_file]
    if file
      set_error :image_file,
                "Image file too large, must be < #{MAXIMAGEFILESIZE/1024} kB,
                      is #{file[:tempfile].size/1024} kB" if file[:tempfile].size > MAXIMAGEFILESIZE
    end
  end

  # Intended for images only...
  def delete_public_file(fn)
    if fn
      File.delete "#{PUBLIC_FOLDER}/"+fn
    end
  end

  #get "public/:fname" do # see _image_rect.erb
   # send_file("#{PUBLIC_FOLDER}/"+params[:fname])
  #end

  get "/" do
    redirect '/login' unless @current_user

    #collect all activities
    activities = []
    if(@current_agent.respond_to?('following'))
      for u in @current_agent.following do
        activities.concat(u.activities)
      end
    end

    activities.sort! {|a,b| b.timestamp <=> a.timestamp}

    erb :marketplace, :locals => {:activity_list => activities}
  end

  get "/strongpass" do
    erb :strongpass
  end

  get "/all_users" do
    redirect '/login' unless session[:user_id]
    erb :userlist
  end

  get "/error" do
    erb :error
  end

