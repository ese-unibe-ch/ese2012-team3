require "test/unit"

class MyTest < Test::Unit::TestCase

  def setup
    User.delete_all
  end

  def test_attributes
    user = User.init(:name => "user1", :password => "Zz!45678")
    time = Time.now
    act = Activity.init(:creator => user, :type => :comment, :message => "Test message")
    assert (act.message == "Test message")
    assert(act.creator == user)
    assert(act.type == :comment)
    assert(time - act.timestamp > -0.00009)
  end

end