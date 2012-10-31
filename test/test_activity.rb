require "test/unit"

class MyTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    User.delete_all
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_attributes
    user = User.init(:name => "user1", :password => "Zz!45678")
    time = Time.now
    act = Activity.init(:creator => user, :type => :comment, :message => "Test message")
    assert (act.message == "Test message")
    assert(act.creator == user)
    assert(act.type == :comment)
    puts (time - act.timestamp)
    assert(time - act.timestamp > -0.00009)
  end

end