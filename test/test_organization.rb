include Market

class OrganizationTest < Test::Unit::TestCase



  def setup
    Organization.delete_all
    @user = User.init(:name => "testuser", :credit => 500, :password => 'Ax1301!3')
  end
  def teardown
    User.delete_all
  end

  def test_has_admin
    org = Organization.init(:name => "org1", :admin => @user)
    assert_equal(@user, org.admin)
  end

  def test_has_name
    org = Organization.init(:name => "org1", :admin => @user)
    assert(org.name.to_s.include?("org1"), "name is not org1!")
  end

  def test_has_name_and_credit
    org = Organization.init(:name => "org2", :credit => 200, :admin => @user)
    assert(org.name.to_s.include?("org2"), "name is not org2!")
    assert(org.credit == 200, "credit is not 200!")
  end

  def test_has_initial_credit
    org = Organization.init(:name => "org3", :admin => @user)
    assert(org.credit == 100, "initial credit is not 100!")
  end

  def test_has_more_credit
    org = Organization.init(:name => "org4", :admin => @user)
    org.increase_credit(50)
    assert(org.credit == 150, "credit is not 150!")
  end

  def test_has_less_credit
    org = Organization.init(:name => "org5", :admin => @user)
    org.decrease_credit(50)
    assert(org.credit == 50, "credit is not 50!")
  end

  def test_add_item
    # list is empty now
    org = Organization.init(:name => "org6", :admin => @user)
    assert(Item.sell_items_by_agent(org).length == 0, "sell list is not empty")
    someitem = Item.init(:name => "someItem", :price => 300)
    someitem.owner = Organization.init(:name => "owner1", :admin => @user)
    org.add_item(someitem)
    assert(Item.sell_items_by_agent(org).include?(someitem), "item was not added!")
  end

  def test_list_all_sell_items
    otheritem = Item.init(:name => "otherItem", :price => 50)
    someitem = Item.init(:name => "someItem", :price => 550)
    otheritem.owner = Organization.init(:name => "owner2", :admin => @user)
    org = Organization.init(:name => "org7", :admin => @user)
    org.add_item(otheritem)
    org.add_item(someitem)
    # list should have 2 sell items now
    assert(Item.sell_items_by_agent(org).length == 2, "there are not 2 items in the sell list!")
    assert(Item.sell_items_by_agent(org).include?(otheritem), "otherItem is not in the sell list!")
    assert(Item.sell_items_by_agent(org).include?(someitem), "someItem is not in the sell list!")
  end

  def test_fail_not_enough_credit
    item = Item.init(:name => "reallyExpensiveItem", :price => 5000)
    org = Organization.init(:name => "org8", :admin => @user)
    owner = Organization.init(:name => "owner3", :admin => @user)
    owner.add_item(item)
    assert_raise RuntimeError do
      org.buy_item(item)
    end
  end

  def test_become_owner_at_trade
    org = Organization.init(:name => "org9", :admin => @user)
    item = Item.init(:credit => 100)
    owner = Organization.init(:name => "owner4", :admin => @user)
    owner.add_item(item)
    org.buy_item(item)
    assert_equal(1, Item.items_by_agent(org).length, "org was not able to buy!")
    assert_equal(org, item.owner, "org is not the owner!")
  end

  def test_transfer_credit_at_trade
    org = Organization.init(:name => "org10", :admin => @user)
    item = Item.init(:name => "normalItem", :price => 100)
    owner = Organization.init(:name => "owner5", :admin => @user)
    owner.add_item(item)
    org.buy_item(item)
    assert_equal(0, org.credit, "org has too much credit!")
    assert_equal(200, owner.credit, "owner has too less credit!")
  end

  def test_removes_from_org
    org = Organization.init(:name => "org11", :admin => @user)
    item = Item.init(:name => "normalItem", :price => 100)
    owner = Organization.init(:name => "owner6", :admin => @user)
    owner.add_item(item)
    org.buy_item(item)
    assert_equal(0, Item.sell_items_by_agent(owner).length, "owner still has the item on his list!")
  end

  def test_fail_inactive
    org = Organization.init(:name => "org12", :admin => @user)
    owner = Organization.init(:name => "owner7", :admin => @user)
    item = Item.init(:active => false, :owner => owner)
    assert_raise RuntimeError do
      org.buy_item(item)
    end
  end

  def test_buy_nil_item_fails
    org = Organization.init(:name => "org13", :admin => @user)
    owner = Organization.init(:name => "owner8", :admin => @user)
    item = nil
    assert_raise RuntimeError do
      org.buy_item(item)
    end
  end

  def test_buy_from_self_fails
    org = Organization.init(:name => "org14", :admin => @user)
    owner = org
    item = Item.init(:active => false, :owner => owner)
    assert_raise RuntimeError do
      org.buy_item(item)
    end
  end

  def test_all_orgs
    org = Organization.init(:name => "org15", :admin => @user)
    org2 = Organization.init(:name => "owner9", :admin => @user)
    # we should have 2 students now
    assert_equal(2, Organization.all.length, "there are not 2 orgs in the orgs list!")
  end

  def test_members
    donald = User.init(:name => "donald", :password => 'Ax1301!3')
    dagobert = User.init(:name => "dagobert", :password => 'Ax1301!3')

    org = Organization.init(:name => "org15", :admin => @user)
    org2 = Organization.init(:name => "owner9", :admin => @user)

    org.add_member(donald)
    org2.add_member(donald)

    org2.add_member(dagobert)

    assert_equal(2, Organization.organizations_by_user(donald).size, "donald not in 2 orgs")
    assert_equal(1, Organization.organizations_by_user(dagobert).size, "dagobert not in 1 org")
    assert_equal(2, org2.members.size, "org2 doesn't have 2 members")
    assert_equal(1, org.members.size, "org2 doesn't have 1 member")

    dagobert.delete

    assert_equal(2, Organization.organizations_by_user(donald).size, "donald not in 2 orgs")
    assert_equal(1, org2.members.size, "org2 doesn't have 1 members")
    assert_equal(1, org.members.size, "org2 doesn't have 1 member")
  end

  def test_get_by_id
    org = Organization.init(:name => "org15", :admin => @user)
    org2 = Organization.init(:name => "owner9", :admin => @user)

    assert_equal(org, Organization.organization_by_id(0))
    assert_equal(org2, Organization.organization_by_id(1))
    assert_nil(Organization.organization_by_id(2))
  end
end