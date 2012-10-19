# Common requs
require 'rubygems'
require 'require_relative'
require_relative 'models'

# App-only requirements
require 'sinatra'
require 'erb'
require_relative 'helpers'

# Controllers
require_relative 'controllers/main'
require_relative 'controllers/authentication'
require_relative 'controllers/user'
require_relative 'controllers/organization'
require_relative 'controllers/marketplace'

include Market

# ===================== Constants =====================
def relative(path)
  File.join(File.expand_path(File.dirname(__FILE__)), path)
end
PUBLIC_FOLDER          = relative('public')
VIEWS_FOLDER           = relative('views')
DEFAULT_PASSWORD       = "Ax1301!3"
DEFAULT_CREDITS        = 200
MAXIMAGEFILESIZE       = 400*1024 # in bytes
LISTIMAGESIZE          = 64 # in pixels
LISTROWWITHIMAGEHEIGHT   = LISTIMAGESIZE + 8 # 72
LARGEIMAGESIZE         = 300
USERIMAGESROOT         = "userimages" # relative to public
ITEMIMAGESROOT         = "itemimages" # relative to public
ORGANIZATIONIMAGESROOT = "organizationimages" # relative to public

enable :sessions
set :public_folder, relative('public')
set :views, relative('views')
DEFAULT_PASSWORD = "Ax1301!3"
MAXIMAGEFILESIZE = 400*1024 # in bytes

# configure do
set :public_folder, PUBLIC_FOLDER # http://www.sinatrarb.com/configuration.html
set :views, VIEWS_FOLDER
enable :sessions # never forget

# ===================== TEST DATA =====================
john = User.init(:name => "John", :credit => 500, :password => DEFAULT_PASSWORD)
User.init(:name => "Jimmy", :credit => 30, :password => DEFAULT_PASSWORD)
User.init(:name => "Jack", :credit => 400, :password => DEFAULT_PASSWORD)
ese = User.init(:name => "ese", :credit => 1000, :password => DEFAULT_PASSWORD)

eseo = Organization.init(:name => "The ESE Organization", :credit => 10000, :admin => ese)
eseo.add_item(Item.init(:name => "pizza", :price => 18, :active => true, :owner => eseo))

uno = Organization.init(:name => "UNO", :credit => 1000, :about => 'united nations', :admin => john)
uno.add_item(Item.init(:name => "blue beret", :price => 10, :active => true, :owner => uno))
uno.add_item(Item.init(:name => "map of the world", :price => 75, :active => true, :owner => uno))

User.all.each_with_index do |user, i|
  item = Item.init(:name => "item" + i.to_s, :price => 100)
  user.add_item(item)
  Item.init(:name => "secondItem", :price => 200, :active => false, :owner => john) if i == 2
end
# end


error do
  erb :error, :locals => {:message => request.env['sinatra.error'].message }
end