class UserTest < Test::Unit::TestCase

  def setup
    Organization.delete_all
    User.delete_all
    Item.delete_all
  end

  def test_all_users
    User.all.delete_if { |user| user != nil }
    user = User.init(:name => "user15", :password => "Zz!45678")
    owner = User.init(:name => "owner9", :password => "Zz!45678")
    # we should have 2 users now
    assert_equal(2, User.all.length, "there are not 2 users in the users list!")
  end

  def test_delete_user
    donald = User.init(:name => "donald", :password => "Zz!45678")
    dagobert = User.init(:name => "dagobert", :password => "Zz!45678")
    assert_equal(2, User.all.size)
    assert_equal(dagobert, User.user_by_name('dagobert'))

    dagobert.delete
    assert_equal(1, User.all.size)
    assert_nil(User.user_by_name('dagobert'))
  end

  def test_delete_items_when_user_deleted
    donald = User.init(:name => "donald", :password => "Zz!45678")
    dagobert = User.init(:name => "dagobert", :password => "Zz!45678")
    beer = Item.init(:name => 'beer', :owner => donald)
    pizza = Item.init(:name => 'pizza', :owner => donald)
    sandwich = Item.init(:name => 'sandwich', :owner => dagobert)

    assert_equal(2, User.all.size)
    assert_equal(3, Item.all.size)

    donald.delete
    assert_equal(1, User.all.size)
    assert_equal(1, Item.all.size)
    assert(!Item.all.include?(beer))
    assert(!Item.all.include?(pizza))
    assert(Item.all.include?(sandwich))
  end

  def test_get_user_by_id
    donald = User.init(:name => "donald", :password => "Zz!45678")
    dagobert = User.init(:name => "dagobert", :password => "Zz!45678")
    assert_equal(donald, User.user_by_id(0))
    assert_equal(dagobert, User.user_by_id(1))
    assert_raise RuntimeError do
      User.user_by_id(2)
    end
  end

  def test_follow
    donald = User.init(:name => "donald", :password => "Zz!45678")
    dagobert = User.init(:name => "dagobert", :password => "Zz!45678")
    donald.follow(dagobert)
    assert(donald.following.include?(dagobert))
    donald.follow(dagobert)
    assert(!donald.following.include?(dagobert))
  end

  def test_is_admin_in_one?
    dagobert = User.init(:name => "dagobert", :password => 'Ax1301!3')

    org = Organization.init(:name => "org15", :admin => dagobert)
    assert(dagobert.is_admin?)
  end

  def test_is_admin_in_two?
    dagobert = User.init(:name => "dagobert", :password => 'Ax1301!3')

    org1 = Organization.init(:name => "org15", :admin => dagobert)
    org1 = Organization.init(:name => "org16", :admin => dagobert)
    assert(dagobert.is_admin?)
  end

  def test_is_not_admin?
    dagobert = User.init(:name => "dagobert", :password => 'Ax1301!3')
    assert(!dagobert.is_admin?)
  end

  def test_is_member_of?
    donald = User.init(:name => "donald", :password => "Zz!45678")
    dagobert = User.init(:name => "dagobert", :password => 'Ax1301!3')
    org = Organization.init(:name => "org", :admin => dagobert)
    org1 = Organization.init(:name => "org1", :admin => donald)
    assert(dagobert.is_member_of?(org))
    assert(!dagobert.is_member_of?(org1))
  end

  def test_all_names
    names = []
    dagobert = User.init(:name => "dagobert", :password => 'Ax1301!3')
    names << "dagobert"
    assert(User.all_names == names)
    donald = User.init(:name => "donald", :password => 'Ax1301!3')
    names << "donald"
    assert(User.all_names == names)
  end

  def test_has_user_with_id?
    dagobert = User.init(:name => "dagobert", :password => 'Ax1301!3')
    assert(User.has_user_with_id?(0))
    assert(!User.has_user_with_id?(1))
    donald = User.init(:name => "donald", :password => 'Ax1301!3')
    assert(User.has_user_with_id?(1))
  end

  def test_profile_route
    dagobert = User.init(:name => "dagobert", :password => 'Ax1301!3')
    assert(dagobert.profile_route == "/profile/0")
  end

end
