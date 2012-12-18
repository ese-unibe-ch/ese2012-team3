class AgentTest < Test::Unit::TestCase

  def setup
    Organization.delete_all
    User.delete_all
    Item.delete_all
  end

  def test_has_name_and_can_be_following
    agent = User.init(:name => "agent1", :password => "Zz!45678")
    assert(agent.name.to_s.include?("agent1"), "name is not agent1!")
    assert(agent.following.length == 0, "agent cannot follow anybody")
  end

  def test_has_name_and_credit
    agent = User.init(:name => "agent2", :credit => 200, :password => "Zz!45678")
    assert(agent.name.to_s.include?("agent2"), "name is not agent2!")
    assert(agent.credit == 200, "credit is not 200!")
  end

  def test_has_initial_credit
    agent = User.init(:name => "agent3", :password => "Zz!45678")
    assert(agent.credit == 100, "initial credit is not 100!")
  end

  def test_has_more_credit
    agent = User.init(:name => "agent4", :password => "Zz!45678")
    agent.increase_credit(50)
    assert(agent.credit == 150, "credit is not 150!")
  end

  def test_has_less_credit
    agent = User.init(:name => "agent5", :password => "Zz!45678")
    agent.decrease_credit(50)
    assert(agent.credit == 50, "credit is not 50!")
  end

  def test_add_item
    # list is empty now
    agent = User.init(:name => "agent6", :password => "Zz!45678")
    assert(Item.sell_items_by_agent(agent).length == 0, "sell list is not empty")
    someitem = Item.init(:name => "someItem", :price => 300, :owner => agent)
    someitem.owner = User.init(:name => "owner1", :password => "Zz!45678")
    agent.add_item(someitem)
    assert(Item.sell_items_by_agent(agent).include?(someitem), "item was not added!")
  end

  def test_list_all_sell_items

    agent = User.init(:name => "agent7", :password => "Zz!45678")
    otheritem = Item.init(:name => "otherItem", :price => 50,:owner => User.init(:name => "owner2", :password => "Zz!45678"))
    someitem = Item.init(:name => "someItem", :price => 550,:owner => agent)

    agent.add_item(otheritem)
    agent.add_item(someitem)
    # list should have 2 sell items now
    assert(Item.sell_items_by_agent(agent).length == 2, "there are not 2 items in the sell list!")
    assert(Item.sell_items_by_agent(agent).include?(otheritem), "otherItem is not in the sell list!")
    assert(Item.sell_items_by_agent(agent).include?(someitem), "someItem is not in the sell list!")
  end

  def test_fail_not_enough_credit
    agent = User.init(:name => "agent8", :password => "Zz!45678")
    item = Item.init(:name => "reallyExpensiveItem", :price => 5000, :owner => agent)

    owner = User.init(:name => "owner3", :password => "Zz!45678")
    owner.add_item(item)
    assert_raise RuntimeError do
      agent.buy_item(item)
    end
  end

  def test_become_owner_at_trade
    agent = User.init(:name => "agent9", :password => "Zz!45678")
    item = Item.init(:credit => 100, :owner => agent)
    owner = User.init(:name => "owner4", :password => "Zz!45678")
    owner.add_item(item)
    agent.buy_item(item)
    assert_equal(1, Item.items_by_agent(agent).length, "agent was not able to buy!")
    assert_equal(agent, item.owner, "agent is not the owner!")
  end

  def test_transfer_credit_at_trade
    agent = User.init(:name => "agent10", :password => "Zz!45678")
    item = Item.init(:name => "normalItem", :price => 100, :owner => agent)
    owner = User.init(:name => "owner5", :password => "Zz!45678")
    owner.add_item(item)
    agent.buy_item(item)
    assert_equal(0, agent.credit, "agent has too much credit!")
    assert_equal(200, owner.credit, "owner has too less credit!")
  end

  def test_removes_from_agent
    agent = User.init(:name => "agent11", :password => "Zz!45678")
    item = Item.init(:name => "normalItem", :price => 100,:owner => agent)
    owner = User.init(:name => "owner6", :password => "Zz!45678")
    owner.add_item(item)
    agent.buy_item(item)
    assert_equal(0, Item.sell_items_by_agent(owner).length, "owner still has the item on his list!")
  end

  def test_fail_inactive
    agent = User.init(:name => "agent12", :password => "Zz!45678")
    owner = User.init(:name => "owner7", :password => "Zz!45678")
    item = Item.init(:active => false, :owner => owner)
    assert_raise RuntimeError do
      agent.buy_item(item)
    end
  end

  def test_buy_nil_item_fails
    agent = User.init(:name => "agent13", :password => "Zz!45678")
    item = nil
    assert_raise RuntimeError do
      agent.buy_item(item)
    end
  end

  def test_buy_from_self_fails
    agent = User.init(:name => "agent14", :password => "Zz!45678")
    owner = agent
    item = Item.init(:active => false, :owner => owner)
    assert_raise RuntimeError do
      agent.buy_item(item)
    end
  end

end
