class MyTest < Test::Unit::TestCase

  def setup
    User.delete_all
  end

  def test_attributes
    user = User.init(:name => "user1", :password => "Zz!45678")
    time = Time.now
    a = {:name => "test item"}
    def a.name
      return self[:name]
    end
    act = Activity::new_comment_activity(user, a)
    assert(act.message.message_ary[1] == " #{a.name}")
    assert(act.creator == user)
    assert(act.type == :comment)
    assert(time - act.timestamp > -0.00009) # this might fail sometimes if ruby feels like it

    # assert cannot change attributes
    assert_raise NoMethodError do
      act.type = :test
    end
  end

end
