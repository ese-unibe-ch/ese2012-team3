require 'erb'

class Main < Sinatra::Application

  def includeERB(path)
    content = File.read($VIEWS_FOLDER + "/" + path)
    t = ERB.new(content)
    t.result(binding)
  end

  get "/" do
    redirect '/login' unless session[:name]

    @current_name = session[:name]
    @users = Market::User.all

    template = ERB.new File.new($VIEWS_FOLDER + "/marketplace.erb").read, nil, "%"
    template.result(binding)
  end

  get "/all_users" do
    redirect '/login' unless session[:name]

    @current_name = session[:name]
    @users = Market::User.all

    template = ERB.new File.new($VIEWS_FOLDER + "/userlist.erb").read, nil, "%"
    template.result(binding)
  end

  get "/profile/:username" do
    redirect '/login' unless session[:name]

    @user = Market::User.user_by_name(params[:username])

    template = ERB.new File.new($VIEWS_FOLDER + "/userprofile.erb").read, nil, "%"
    template.result(binding)
  end

  get "/error" do
    redirect '/login' unless session[:name]

    template = ERB.new File.new($VIEWS_FOLDER + "/error.erb").read, nil, "%"
    template.result(binding)
  end

end
