# Run this to run the model tests. Defines all required includes plus some commonly required mock methods.

# Common requs
require 'rubygems'
require 'require_relative'
require_relative '../app/models.rb'

# App specifique requirements
require "rufus-scheduler"

# Test requs
require "test/unit"

# Mock method
def delete_public_file(fn)
  # do nothing
end


# Include (= run) tests
require_relative 'test_organization.rb'
require_relative 'test_user.rb'
require_relative 'test_agent.rb'
require_relative 'test_item.rb'
require_relative 'test_password_check.rb'
require_relative 'test_comment.rb'
require_relative 'test_activity.rb'
require_relative 'test_auction.rb'
require_relative 'test_timed_event.rb'
require_relative 'test_safe.rb'
