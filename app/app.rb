# encoding: utf-8

# This is the main application file. It states all includes only required for the full application (that is model and controllers).
# If also does the setup and defines constants.


# Common requs
require 'rubygems'
require 'require_relative'
require_relative 'models'

# App-only requirements
require 'sinatra'
require 'erb'
require 'redcarpet'
require 'rufus/scheduler'
require 'sinatra/flash'

require_relative 'helpers'

# Controllers
require_relative 'controllers/main'
require_relative 'controllers/authentication'
require_relative 'controllers/user'
require_relative 'controllers/organization'
require_relative 'controllers/marketplace'
require_relative 'controllers/language'
require_relative 'controllers/admin'

include Market

# @return a full path
# @param path [String] a path relative to this source code file
def relative(path)
  File.join(File.expand_path(File.dirname(__FILE__)), path)
end

# ===================== Constants =====================

PUBLIC_FOLDER          = relative('public')
VIEWS_FOLDER           = relative('views')

DEFAULT_LANGUAGE       = "en"
LANGUAGES_FOLDER       = relative('public/languages')
LANGUAGES              = {} # a map of language prefix => {Language} object
KEY_CATEGORIES         = {} # a map of "cartegory name" => array of language keys

DEFAULT_PASSWORD       = "Ax1301!3"
DEFAULT_CREDITS        = 200
ADMIN_USERNAME         = 'admin'
ADMIN_PASSWORD         = 'password'
ADMIN_AREA_LOGIN_MESSAGE = "Restricted Area"
ADMIN_USERLIST_REFRESH_MS = 30*1000
ADMIN_USERLIST_LAST_ACTION_AT_MOST_AGO_SEC = 5*60

MAXIMAGEFILESIZE       = 400*1024 # in bytes
LISTIMAGESIZE          = 64 # in pixels
LISTROWWITHIMAGEHEIGHT = LISTIMAGESIZE + 8 # 72
LARGEIMAGESIZE         = 300
SMALLIMAGESIZE         = 100
USERIMAGESROOT         = "userimages" # relative to {PUBLIC_FOLDER}
ITEMIMAGESROOT         = "itemimages" # relative to {PUBLIC_FOLDER}
ORGANIZATIONIMAGESROOT = "organizationimages" # relative to {PUBLIC_FOLDER}

ITEMS_PER_PAGE         = 20
AGENTS_PER_PAGE        = 20
ACTIVITIES_PER_PAGE    = 7
COMMENTS_PER_PAGE      = 20

DUMMYTHINGSCOUNT       = 30

# Set constans in sinatra
set :public_folder, relative('public')
set :views, relative('views')

# configure do # not used
set :public_folder, PUBLIC_FOLDER # http://www.sinatrarb.com/configuration.html
set :views, VIEWS_FOLDER
#set :port, 80
enable :sessions # never forget

# ===================== Load languages =====================
load_languages(LANGUAGES_FOLDER)

# ===================== Global error handler =====================
error do
  erb :error, :locals => {:message => request.env['sinatra.error'].message }
end

# ===================== TEST DATA =====================
# You can delete or "if 0==1 ... end"-out all of the code below till the end of this file
#if 0 == 1
john = User.init(:name => "John", :credit => 500, :password => DEFAULT_PASSWORD)
jimmy = User.init(:name => "Jimmy", :credit => 30, :password => DEFAULT_PASSWORD)
jack = User.init(:name => "Jack", :credit => 400, :password => DEFAULT_PASSWORD)
ese = User.init(:name => "ese", :credit => 1000, :password => DEFAULT_PASSWORD)
ese.password = "ese"
john.image_file_name="userimages/1.png"
jimmy.image_file_name="userimages/1.png"
jack.image_file_name="userimages/1.png"
ese.image_file_name="userimages/1.png"
eseo = Organization.init(:name => "The ESE Organization", :credit => 10000, :admin => ese)
uno = Organization.init(:name => "UNO", :credit => 1000, :about => '**the** united nations', :admin => john)
uno.image_file_name="userimages/1.png"
eseo.image_file_name="userimages/1.png"


# followings
john.follow(jack)
john.follow(jimmy)
john.follow(uno)
ese.follow(john)
ese.follow(jimmy)
ese.follow(uno)

# Demonstrate multi language about and name
pizza_about =  {
  "en" =>
  "Comes with

  * mozzarella
  * garlic
  * __bacon__",
  "de" =>
  "Belegt mit

  * Mozzarella
  * Knoblauch
  * __Speck__",
  "fr" =>
  "Avec:

  * mozzarella
  * ail
  * __bacon__",
  "jp" =>
  "トッピング は

  * モツァレラ
  * ニンニク
  * __ベーコン__"}

pizza_name = {"de"=>"Leckere Pizza", "en"=>"Delicious Pizza", "fr" => "Pizza délicieuse", "jp" => "おいしいピザ"}

pizza = Item.init(:name => pizza_name, :price => 18, :about => pizza_about, :active => true, :owner => eseo)
pizza.image_file_name="itemimages/pizza.png"
#activities
eseo.add_activity(Activity::new_comment_activity(eseo, pizza))
ese.add_activity(Activity::new_comment_activity(ese, pizza))

john.add_activity(Activity::new_follow_activity(john, ese))
john.add_activity(Activity::new_activate_activity(john, pizza))
john.add_activity(Activity::new_comment_activity(john, pizza))

# Some dummy users to test paging
for i in 0...DUMMYTHINGSCOUNT
  dummyUser = User.init(:name => "dummyuser"+i.to_s, :credit => 1000, :password => DEFAULT_PASSWORD, :about => "This is a dummy user. Please just leave him alone.")
  dummyUser.image_file_name="userimages/1.png"
  ese.follow(dummyUser)
end


eseo.add_item(pizza)
pizza.add_comment(Comment.new(:creator => john, :text => "can i get that without the garlic?"))
beret = Item.init(:name => "blue beret", :price => 10, :active => true, :owner => uno)
beret.image_file_name="itemimages/beret.jpg"
uno.add_item(beret)
map = Item.init(:name => "map of the world", :price => 75, :active => true, :owner => uno)
map.image_file_name="itemimages/map.jpg"
uno.add_item(map)
User.all.each_with_index do |user, i|
  about = "This is a **Pet Rock**. It's very easy to keep, doesn't need any special diet; it's house-trained."
  item = Item.init(:name => "Pet Rock", :price => 100, :owner => user, :about => about)
  comment = Comment.new(:creator => user, :text => "This is my rock. I want to sell it")
  item.add_comment(comment)
  item.add_comment(Comment.new(:creator => user, :text => "Very *nice* rock! And **cheap**"))
  item.add_comment(Comment.new(:creator => john, :text => "I'll give you **10** credits, max!"))
  item.image_file_name="itemimages/stone.jpg"
  user.add_item(item)

  ese.change_wishlist(item) # Add to wishlist. ese loves pet rocks huh!? xD

  Item.init(:name => "secondItem", :price => 200, :active => false, :owner => john) if i == 2
end

# Some dummy offers to test paging
lastdummyitem = nil
for i in 0...DUMMYTHINGSCOUNT
  dummyabout = "**this** *is* a\n\n* dummy\n\n1. offer"
  safe = Safe.new
  price = rand(10)+1
  safe.fill(uno, price)
  lastdummyitem = Item.init(:name => "dummyoffer"+i.to_s, :price => price, :active => true, :owner => uno, :about => dummyabout, :offer => true, :safe => safe)
  
  lastdummyitem.image_file_name="itemimages/quarta.jpg"
  Market::Item.add_offer(lastdummyitem)
end

# Some dummy items to test paging
lastdummyitem = nil
for i in 0...DUMMYTHINGSCOUNT
  dummyabout = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua"
  lastdummyitem = Item.init(:name => "dummyitem"+i.to_s, :price => rand(100)+1, :active => true, :owner => uno, :about => dummyabout)
  lastdummyitem.image_file_name="itemimages/quarta.jpg"
  uno.add_item(lastdummyitem)
end



# Some dummy comments to test paging to LAST dummyitem
for i in 0...DUMMYTHINGSCOUNT
  lastdummyitem.add_comment(Comment.new(:creator => jack, :text => "very *nice* item! And **cheap** the #{i}th"))
end

#end


