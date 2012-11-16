class ItemTest < Test::Unit::TestCase

  def setup
    Item.delete_all
    User.delete_all
    @user = User.init(:name => "John", :password => "Zz!45678",:owner => @user)
  end

  def test_has_name_about_and_comments
    item = Item.init(:name => "testItem", :about => "About item",:owner => @user)
    assert(item.name.to_s.include?("testItem"), "item has a wrong name!")
    assert(item.about.include?("About item"), "item has no about!")
    assert(item.comments.length == 0, "item has no place to store comments!")

    assert_raise RuntimeError do
      item.name = nil
    end
  end

  def test_has_price
    item = Item.init(:price => 100,:owner => @user)
    assert(item.price == 100, "item has a wrong price!")
    assert(item.about, "item has no default about!")
  end

  def test_has_owner
    item = Item.init(:owner => @user)
    assert_equal(@user, item.owner, "item has an incorrect owner!")
  end

  def test_changes_state
    item = Item.init(:owner => @user)
    item.activate
    assert(item.active, "item is still inactive!")
  end

  def test_is_inactive_after_trade
    user = User.init(:name => "Buyer", :password => "Zz!45678")
    initialOwner = User.init(:name => "Owner", :password => "Zz!45678")
    item = Item.init(:name => "normalItem", :price => 100, :owner => initialOwner, :active => true)
    user.buy_item(item)
    assert(!Item.sell_items_by_agent(user).include?(item), "item is still active!")
  end

  def test_user_has_item_without_add
    user = User.init(:name => "user1", :password => "Zz!45678")
    item = Item.init(:name => "testItem", :owner => user)
    assert(item.owner == user, "user is not the owner!")
    assert(Item.items_by_agent(user).include?(item), "user doesn't have the item!")
  end

  def test_item_has_id
    user = User.init(:name => "user20", :password => "Zz!45678")
    item = Item.init(:name => "testItem", :owner => user)
    assert_not_nil(item.id, "ID is not correct")
  end

  def test_item_by_id
    user = User.init(:name => "user21", :password => "Zz!45678")
    item = Item.init(:name => "testItem", :owner => user)
    item2 = Item.init(:name => "testItem", :owner => user)
    assert(Item.by_id(item2.id.to_i) == item2)
  end

  def test_delete_item
    user = User.init(:name => "user21", :password => "Zz!45678")
    item = Item.init(:name => "testItem", :owner => user)
    item2 = Item.init(:name => "testItem", :owner => user)
    assert_equal(2, Item.all.size)

    item2.delete
    assert_equal(1, Item.all.size)
    assert_equal(item, Item.all.first)
    assert_nil(Item.all[1])
  end

end
