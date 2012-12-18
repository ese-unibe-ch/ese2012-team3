class MyTest < Test::Unit::TestCase

  def setup
    User.delete_all
    @user = User.init(:name => "user1", :password => "Zz!45678")
    @time = Time.now
    @i = {:name => "test item"}
    def @i.name
      return self[:name]
      end
  end

  def test_comment_activity
    act = Activity::new_comment_activity(@user, @i)
    assert(act.message.message_ary[2] == "#{@i.name}") # message_ary supposed to be ["COMMENTED_ON", " ", item.name.clone]
    assert(act.creator == @user)
    assert(act.type == :comment)
    assert(@time - act.timestamp > -0.00009) # this might fail sometimes if ruby feels like it
    # assert cannot change attributes
    assert_raise NoMethodError do
      act.type = :test
    end
  end

  def test_item_activity
    act = Activity::new_createitem_activity(@user, @i)
    assert(act.message.message_ary[2] == "#{@i.name}") # message_ary supposed to be ["CREATED_ITEM", " ", item.name.clone]
    assert(act.creator == @user)
    assert(act.type == :createitem)
    assert(@time - act.timestamp > -0.00009) # this might fail sometimes if ruby feels like it
                                                       # assert cannot change attributes
    assert_raise NoMethodError do
      act.type = :test
    end
  end

  def test_follow_activity
    @follow =  User.init(:name => "FollowMe", :password => "Zz!45678")
    act = Activity::new_follow_activity(@user, @follow)
    assert(act.message.message_ary[1] == " FollowMe") # message_ary supposed to be ["FOLLOWS", " ", follow.name]
    assert(act.creator == @user)
    assert(act.type == :follow)
    # assert cannot change attributes
    assert_raise NoMethodError do
      act.type = :test
    end
  end

  def test_activate_activity
    act = Activity::new_activate_activity(@user, @i)
    assert(act.message.message_ary[2] == "#{@i.name}") # message_ary supposed to be ["ACTIVATED_ITEM", " ", item.name.clone]
    assert(act.creator == @user)
    assert(act.type == :activate)
    assert(@time - act.timestamp > -0.00009) # this might fail sometimes if ruby feels like it
                                                       # assert cannot change attributes
    assert_raise NoMethodError do
      act.type = :test
    end
  end

  def test_buy_activity
    act = Activity::new_buy_activity(@user, @i)
    assert(act.message.message_ary[2] == "#{@i.name}") # message_ary supposed to be ["BOUGHT_ITEM", " ", item.name.clone]
    assert(act.creator == @user)
    assert(act.type == :buy)
    assert(@time - act.timestamp > -0.00009) # this might fail sometimes if ruby feels like it
                                                       # assert cannot change attributes
    assert_raise NoMethodError do
      act.type = :test
    end
  end




end
