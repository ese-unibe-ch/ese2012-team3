# This defines helpers used by the controllers and views.

module SecurityHelpers
    def xss(text)
      escaped = Rack::Utils.escape_html(text)
      escaped.gsub("&gt;", ">")
    end
end

module NumericHelpers
  def ts(s)
    s.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1'")
  end
end

module MarkupHelpers
  def mdown_to_html(mdown)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    markdown.render(mdown)
  end
end


def random_first_name
  first_names = ["James", "John", "Robert", "Michael", "William", "David", "Richard", "Charles", "Joseph", "Thomas", "Christopher", "Daniel", "Paul", "Mark", "Donald", "George", "Kenneth", "Steven", "Edward", "Brian", "Ronald", "Anthony", "Kevin", "Jason", "Matthew", "Gary", "Timothy", "Jose", "Larry", "Jeffrey", "Frank", "Scott", "Eric", "Stephen", "Andrew", "Raymond", "Gregory", "Joshua", "Jerry", "Dennis", "Walter", "Patrick", "Peter", "Harold", "Douglas", "Henry", "Carl", "Arthur", "Ryan", "Roger"]
  return first_names[rand(first_names.length)]
end

def random_surname
  surnames = ["Smith", "Jones", "Taylor", "Williams", "Brown", "Davies", "Evans", "Wilson", "Thomas", "Roberts", "Johnson", "Lewis", "Walker", "Robinson", "Wood", "Thompson", "White", "Watson", "Jackson", "Wright", "Green", "Harris", "Cooper", "King", "Lee", "Martin", "Clarke", "James", "Morgan", "Hughes", "Edwards", "Hill", "Moore", "Clark", "Harrison", "Scott", "Young", "Morris", "Hall", "Ward", "Turner", "Carter", "Phillips", "Mitchell", "Patel", "Adams", "Campbell", "Anderson", "Allen", "Cook"]
  return surnames[rand(surnames.length)]
end

def random_item_attribute
  attributes = ["New", "Old", "Used", "Delicious", "Excellent", "Dubious", "Dusty", "Great", "Blue", "Green", "Yellow", "Red", "Simple", "Striped", "Antique", "Lovely", "Shabby", "Awesome", "Mysterious", "Fresh", "Cool", "Unused", "Slightly used", "Perfect"]
  return attributes[rand(attributes.length)]
end

def random_item_name
  items = ["pizza", "cupboard", "bike", "bicycle", "car", "laptop", "desk", "lamp", "children's book", "playstation", "gloves", "hockey stick", "basketball", "football", "soccer shoes", "shoes", "shoe", "shirt", "coat", "hat", "painting", "photograph of a dog", "dog", "book", "novel", "newspaper", "pants", "mp3 player", "walkman", "tv", "radio", "car radio", "cell", "sled", "dvd", "snowboard", "snowman", "leaf", "stick", "stone", "rock", "trash can", "bottle o' rum", "tricycle", "child", "cat", "baseball bat", "soul"]
  return items[rand(items.length)]
end

# ================= Client area (Marketplace) ================

# Redirects to login if not logged in.
def ensure_logged_in!
  redirect '/login' unless session[:user_id]
end

def set_error(at, text)
  @errors[at] = text
end

# Returns filename (relative to public) of the image added or nil if image is not present.
# @param file Must have been a "params[:image_file]" as set by Sinatra for file uploads (with image_file[:tempfile] nad image_file[:filename] set)
def add_image(rootdir, id, file)
  return nil unless file
  fn = rootdir+"/#{id}"+File.extname(file[:filename])
  FileUtils::cp(file[:tempfile].path, "#{PUBLIC_FOLDER}/"+fn)
  return fn
end

# sets the :image_file error if there's something wrong with the image provided
def image_file_check
  file = params[:image_file]
  if file
    set_error :image_file, LocalizedMessage.new([ LocalizedMessage::LangKey.new("IMAGE_TOO_LARGE"),
                                                  " < #{MAXIMAGEFILESIZE/1024} kB,  is #{file[:tempfile].size/1024} kB"]) if file[:tempfile].size > MAXIMAGEFILESIZE
  end
end

# Intended for images only...
def delete_public_file(fn)
  if fn && fn.length > 0 && File.exist?(fn)
    File.delete "#{PUBLIC_FOLDER}/"+fn
  end
end

# ================= Admin area ==================
# Shows the admin login if not authenticated
def admin!
  unless authorized?
    response['WWW-Authenticate'] = %(Basic realm="#{ADMIN_AREA_LOGIN_MESSAGE}")
    throw(:halt, [401, "Not authorized\n"])
  end
end

def authorized?
  @auth ||=  Rack::Auth::Basic::Request.new(request.env)
  @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [ADMIN_USERNAME, ADMIN_PASSWORD]
end


helpers SecurityHelpers, NumericHelpers, MarkupHelpers

