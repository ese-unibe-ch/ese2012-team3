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

include Market

# ===================== Constants =====================
def relative(path)
  File.join(File.expand_path(File.dirname(__FILE__)), path)
end
PUBLIC_FOLDER          = relative('public')
VIEWS_FOLDER           = relative('views')

DEFAULT_LANGUAGE       = "en"
LANGUAGES_FOLDER       = relative('public/languages')
LANGUAGES              = {} # a map of language prefix => Language object

DEFAULT_PASSWORD       = "Ax1301!3"
DEFAULT_CREDITS        = 200
MAXIMAGEFILESIZE       = 400*1024 # in bytes
LISTIMAGESIZE          = 64 # in pixels
LISTROWWITHIMAGEHEIGHT = LISTIMAGESIZE + 8 # 72
LARGEIMAGESIZE         = 300
USERIMAGESROOT         = "userimages" # relative to public
ITEMIMAGESROOT         = "itemimages" # relative to public
ORGANIZATIONIMAGESROOT = "organizationimages" # relative to public
ITEMS_PER_PAGE         = 20
AGENTS_PER_PAGE        = 20
ACTIVITIES_PER_PAGE    = 7
COMMENTS_PER_PAGE      = 20
DUMMYTHINGSCOUNT       = 30

set :public_folder, relative('public')
set :views, relative('views')

# configure do
set :public_folder, PUBLIC_FOLDER # http://www.sinatrarb.com/configuration.html
set :views, VIEWS_FOLDER
enable :sessions # never forget

# ===================== Load languages =====================
load_languages(LANGUAGES_FOLDER)


# ===================== TEST DATA =====================
john = User.init(:name => "John", :credit => 500, :password => DEFAULT_PASSWORD)
jimmy = User.init(:name => "Jimmy", :credit => 30, :password => DEFAULT_PASSWORD)
jack = User.init(:name => "Jack", :credit => 400, :password => DEFAULT_PASSWORD)
ese = User.init(:name => "ese", :credit => 1000, :password => DEFAULT_PASSWORD)
john.image_file_name="userimages/1.png"
jimmy.image_file_name="userimages/1.png"
jack.image_file_name="userimages/1.png"
ese.image_file_name="userimages/1.png"
eseo = Organization.init(:name => "The ESE Organization", :credit => 10000, :admin => ese)
uno = Organization.init(:name => "UNO", :credit => 1000, :about => '**the** united nations', :admin => john)
uno.image_file_name="userimages/1.png"
eseo.image_file_name="userimages/1.png"
JACK_USER = jack

# followings
john.follow(jack)
john.follow(jimmy)
john.follow(uno)
ese.follow(john)
ese.follow(jimmy)
ese.follow(uno)

#activities
eseo.add_orgactivity(Activity.init({:creator => ese,
                                    :type => :comment,
                                    :message => "commented on some item - demo activity."}))
ese.add_activity(Activity.init({:creator => ese,
                                   :type => :comment,
                                   :message => "commented on some item - demo activity."}))

john.add_activity(Activity.init({:creator => john,
                                :type => :follow,
                                :message => "followed someone - demo activity."}))
john.add_activity(Activity.init({:creator => john,
                                 :type => :activate,
                                 :message => "activated some item - demo activity."}))
john.add_activity(Activity.init({:creator => john,
                                 :type => :comment,
                                 :message => "commented on something - demo activity."}))

# Some dummy users to test paging
for i in 0...DUMMYTHINGSCOUNT
  dummyUser = User.init(:name => "dummyuser"+i.to_s, :credit => 1000, :password => DEFAULT_PASSWORD, :about => "This is a dummy user. Please just leave him alone.")
  dummyUser.image_file_name="userimages/1.png"
end

pizza_about =
"* mozarella
* garlic
* __bacon__"
pizza = Item.init(:name => "pizza", :price => 18, :about => pizza_about, :active => true, :owner => eseo)
eseo.add_item(pizza)
pizza.add_comment(Comment.init(:creator => john, :text => "can i get that without the garlic?"))
uno.add_item(Item.init(:name => "blue beret", :price => 10, :active => true, :owner => uno))
uno.add_item(Item.init(:name => "map of the world", :price => 75, :active => true, :owner => uno))
User.all.each_with_index do |user, i|
  item = Item.init(:name => "item" + i.to_s, :price => 100, :owner => user)
  comment = Comment.init(:creator => user, :text => "This is **my** item")
  item.add_comment(comment)
  item.add_comment(Comment.init(:creator => user, :text => "very *nice* item! And **cheap**"))
  item.add_comment(Comment.init(:creator => john, :text => "i'll give you **10** credits, max!"))
  user.add_item(item)
  item.image_file_name="userimages/1.png"
  Item.init(:name => "secondItem", :price => 200, :active => false, :owner => john) if i == 2
end

UNO_ORG = uno

# Some dummy items to test paging
lastdummyitem = nil
for i in 0...DUMMYTHINGSCOUNT
  lastdummyitem = Item.init(:name => "dummyitem"+i.to_s, :price => rand(100), :active => true, :owner => uno)
  lastdummyitem.image_file_name="userimages/1.png"
  uno.add_item(lastdummyitem)
end

# Some dummy comments to test paging to LAST dummyitem
for i in 0...DUMMYTHINGSCOUNT
  lastdummyitem.add_comment(Comment.init(:creator => jack, :text => "very *nice* item! And **cheap** the #{i}th"))
end

# end

# ===================== Global error handler =====================
error do
  erb :error, :locals => {:message => request.env['sinatra.error'].message }
end
