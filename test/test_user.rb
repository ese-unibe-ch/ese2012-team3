include Market

class UserTest < Test::Unit::TestCase

  def setup
    User.delete_all
    Item.delete_all
  end

  def test_has_name_and_can_be_following
    user = User.init(:name => "user1", :password => "Zz!45678")
    assert(user.name.to_s.include?("user1"), "name is not user1!")
    assert(user.following.length == 0, "user cannot follow anybody")
  end

  def test_has_name_and_credit
    user = User.init(:name => "user2", :credit => 200, :password => "Zz!45678")
    assert(user.name.to_s.include?("user2"), "name is not user2!")
    assert(user.credit == 200, "credit is not 200!")
  end

  def test_has_initial_credit
    user = User.init(:name => "user3", :password => "Zz!45678")
    assert(user.credit == 100, "initial credit is not 100!")
  end

  def test_has_more_credit
    user = User.init(:name => "user4", :password => "Zz!45678")
    user.increase_credit(50)
    assert(user.credit == 150, "credit is not 150!")
  end

  def test_has_less_credit
    user = User.init(:name => "user5", :password => "Zz!45678")
    user.decrease_credit(50)
    assert(user.credit == 50, "credit is not 50!")
  end

  def test_add_item
    # list is empty now
    user = User.init(:name => "user6", :password => "Zz!45678")
    assert(Item.sell_items_by_agent(user).length == 0, "sell list is not empty")
    someitem = Item.init(:name => "someItem", :price => 300)
    someitem.owner = User.init(:name => "owner1", :password => "Zz!45678")
    user.add_item(someitem)
    assert(Item.sell_items_by_agent(user).include?(someitem), "item was not added!")
  end

  def test_list_all_sell_items
    otheritem = Item.init(:name => "otherItem", :price => 50)
    someitem = Item.init(:name => "someItem", :price => 550)
    otheritem.owner = User.init(:name => "owner2", :password => "Zz!45678")
    user = User.init(:name => "user7", :password => "Zz!45678")
    user.add_item(otheritem)
    user.add_item(someitem)
    # list should have 2 sell items now
    assert(Item.sell_items_by_agent(user).length == 2, "there are not 2 items in the sell list!")
    assert(Item.sell_items_by_agent(user).include?(otheritem), "otherItem is not in the sell list!")
    assert(Item.sell_items_by_agent(user).include?(someitem), "someItem is not in the sell list!")
  end

  def test_fail_not_enough_credit
    item = Item.init(:name => "reallyExpensiveItem", :price => 5000)
    user = User.init(:name => "user8", :password => "Zz!45678")
    owner = User.init(:name => "owner3", :password => "Zz!45678")
    owner.add_item(item)
    assert_raise RuntimeError do
      user.buy_item(item)
    end
  end

  def test_become_owner_at_trade
    user = User.init(:name => "user9", :password => "Zz!45678")
    item = Item.init(:credit => 100)
    owner = User.init(:name => "owner4", :password => "Zz!45678")
    owner.add_item(item)
    user.buy_item(item)
    assert_equal(1, Item.items_by_agent(user).length, "user was not able to buy!")
    assert_equal(user, item.owner, "user is not the owner!")
  end

  def test_transfer_credit_at_trade
    user = User.init(:name => "user10", :password => "Zz!45678")
    item = Item.init(:name => "normalItem", :price => 100)
    owner = User.init(:name => "owner5", :password => "Zz!45678")
    owner.add_item(item)
    user.buy_item(item)
    assert_equal(0, user.credit, "user has too much credit!")
    assert_equal(200, owner.credit, "owner has too less credit!")
  end

  def test_removes_from_user
    user = User.init(:name => "user11", :password => "Zz!45678")
    item = Item.init(:name => "normalItem", :price => 100)
    owner = User.init(:name => "owner6", :password => "Zz!45678")
    owner.add_item(item)
    user.buy_item(item)
    assert_equal(0, Item.sell_items_by_agent(owner).length, "owner still has the item on his list!")
  end

  def test_fail_inactive
    user = User.init(:name => "user12", :password => "Zz!45678")
    owner = User.init(:name => "owner7", :password => "Zz!45678")
    item = Item.init(:active => false, :owner => owner)
    assert_raise RuntimeError do
      user.buy_item(item)
    end
  end

  def test_buy_nil_item_fails
    user = User.init(:name => "user13", :password => "Zz!45678")
    owner = User.init(:name => "owner8", :password => "Zz!45678")
    item = nil
    assert_raise RuntimeError do
      user.buy_item(item)
    end
  end

  def test_buy_from_self_fails
    user = User.init(:name => "user14", :password => "Zz!45678")
    owner = user
    item = Item.init(:active => false, :owner => owner)
    assert_raise RuntimeError do
      user.buy_item(item)
    end
  end

  def test_all_users
    User.all.delete_if { |user| user != nil }
    user = User.init(:name => "user15", :password => "Zz!45678")
    owner = User.init(:name => "owner9", :password => "Zz!45678")
    # we should have 2 students now
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

end