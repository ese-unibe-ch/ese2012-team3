require 'rubygems'
require 'sinatra'
require 'tilt/haml'
require 'app/models/market/user'
require 'app/models/market/item'
require 'app/controllers/main'
require 'app/controllers/authentication'
require 'app/controllers/marketplace'

include Market

class App < Sinatra::Base

  use Authentication
  use Main
  use Marketplace

  enable :sessions
  set :public_folder, 'app/public'

  # a global variable is quite hacky, but it seems to be the only way..
  $VIEWS_FOLDER = File.dirname(__FILE__) + "/views"

  configure :development do
    john = User.init(:name => "John", :credit => 500)
    User.init(:name => "Jimmy", :credit => 300)
    User.init(:name => "Jack", :credit => 400)
    User.init(:name => "ese", :credit => 1000)
    User.all.each_with_index do |user, i|
      item = Item.init(:name => "item" + i.to_s, :price => 100)
      user.add_item(item)
      Item.init(:name => "secondItem", :price => 200, :active => false, :owner => john) if i == 2
    end
  end

  # Run, Forrest, run!
  App.run!
end
