require 'rubygems'
require 'sinatra'
require 'require_relative'
require_relative 'models/market/user'
require_relative 'models/market/item'
require_relative 'controllers/main'
require_relative 'controllers/authentication'
require_relative 'controllers/marketplace'

include Market

def relative(path)
  File.join(File.expand_path(File.dirname(__FILE__)), path)
end
Views = relative('views')

class App < Sinatra::Base

  use Authentication
  use Main
  use Marketplace

  enable :sessions
  set :public_folder, 'app/public'
  set :views, Views

  configure :development do
    defpw = "Ax1301!3";
    john = User.init(:name => "John", :credit => 500, :password => defpw)
    User.init(:name => "Jimmy", :credit => 30, :password => defpw)
    User.init(:name => "Jack", :credit => 400, :password => defpw)
    User.init(:name => "ese", :credit => 1000, :password => defpw)
    User.all.each_with_index do |user, i|
      item = Item.init(:name => "item" + i.to_s, :price => 100)
      user.add_item(item)
      Item.init(:name => "secondItem", :price => 200, :active => false, :owner => john) if i == 2
    end
  end

  # Run, Forrest, run!
  App.run!
end
