class TestAuction < Test::Unit::TestCase
  class MockItem
  end

  class MockUser
    @bought_item = nil

    def id
      1
    end

    def buy_item(item)
      @bought_item = item
    end

    def bought_item
      @bought_item
    end
  end

  def setup
    @item = MockItem.new
    @time = Time.now() + 3600
    @auction = Auction.create(@item, 100, 10, @time)
  end

  def test_should_belong_to_an_item
    assert(@item == @auction.item, "Auction should be the same")
  end

  def test_should_have_price
    assert(@auction.price == 100, "Auction should have 100 as start price")
  end

  def test_should_have_increment
    assert(@auction.increment == 10, "Auction should have increment 10")
  end

  def test_should_have_end_time
    assert(@auction.end_time == @time, "Auction should have @time as start time")
  end

  def test_should_be_editable_after_creation
    assert(@auction.editable?, "Auction should be editable when created")
  end

  def test_should_not_be_closed_when_created
    assert(!@auction.closed?, "Auction should not be closed")
  end

  def test_should_have_no_winner_after_creation
    assert(@auction.winner == nil, "Item should not have a when created")
  end

  def bid
    @user = MockUser.new
    @auction.offer(@user, 200)
  end

  def test_should_have_winner_after_first_bid
    bid
    assert(@auction.winner == @user, "Winner should be user that bidded")
  end

  def test_should_not_increment_start_price_after_first_bid
    bid
    assert(@auction.price == 100, "Price should be incremented after bid")
  end

  def test_should_not_be_editable_when_bids_are_set
    bid
    assert(!@auction.editable?,"Item should not be editable when bids are set")
  end

  def test_should_not_possible_to_bid_when_time_is_up
    @item = MockItem.new
    @time = Time.now() + 1
    @auction = Auction.create(@item, 100, 10, @time)
    sleep(1)

    assert(@auction.closed?, "Should not be possible to bit when time is up")
  end

  def test_should_sell_object_after_time_out_to_highest_bidder
    bid
    @auction.timed_out

    assert(@user.bought_item == @item, "User should have bought item")
  end

  def two_bidders
    @bidder_one = MockUser.new
    @auction.offer(@bidder_one, 200)

    @bidder_two = MockUser.new
    @auction.offer(@bidder_two, 300)
  end

  def test_should_set_bidder_with_higher_bid_as_winner
    two_bidders
    assert(@auction.winner == @bidder_two, "Should set bidder_two as winner but was #{@auction.winner}")
  end

  def test_should_set_price_an_increment_higher_than_bid_of_lower_bidder
    two_bidders
    assert(@auction.price == 210, "Should set bid to 210 but was #{@auction.price}")
  end
end