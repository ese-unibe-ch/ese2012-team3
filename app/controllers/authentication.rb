require 'erb'
def relative path
  File.join(File.dirname(__FILE__), path)
end
require relative('../../app/models/market/user')

class Authentication < Sinatra::Application

  def includeERB(path)
    content = File.read($VIEWS_FOLDER + "/" + path)
    t = ERB.new(content)
    t.result(binding)
  end

  post "/login" do
    username = params[:username]
    password = params[:password]

    fail "User does not exist" unless Market::User.allNames.include?(username)
    fail "Empty username or password" if username.nil? or password.nil?
    fail "Password wrong!" if password != username

    session[:name] = username
    redirect "/?loggedin=true"
  end

  get "/login" do
    redirect '/' if session[:name]

    @current_name = session[:name]

    template = ERB.new File.new($VIEWS_FOLDER + "/login.erb").read, nil, "%"
    template.result(binding)
  end

  get "/logout" do
    session[:name] = nil
    redirect "/login"
  end

end
