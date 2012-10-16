require "rubygems"
require "selenium/webdriver"
require "test/unit"
require 'require_relative'

require_relative "selenium_helper_methods.rb"

# Selenium Tests are run in alphanumerical order (tests also).. weird..
require_relative "selenium_register.rb" # AAA Class
require_relative "selenium_login.rb" # BBB Class
require_relative "selenium_marketplace.rb" # CCC Class
require_relative "selenium_allusers.rb" # DDD Class
require_relative "selenium_additem.rb" # EEE Class
#require_relative "selenium_account.rb" # FFF Class
