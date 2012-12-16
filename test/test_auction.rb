class TestAuction < Test::Unit::TestCase
  class MockItem < Item
    attr_accessor :active, :auction, :name, :price

    def initialize
      self.name = "Item"
    end

    def activate
      self.active = true
    end

    def inactivate
      self.active = false
    end

    def active?
      self.active
    end

    def id
      1
    end
  end

  class MockUser < User
    attr_accessor :credit, :bought_item, :name

    def initialize
      self.credit = 600
      self.bought_item = nil
      self.name = "Hans"
    end

    def id
      1
    end

    def buy_item(item)
      @bought_item = item
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

  def test_should_have_minimal_price
    assert(@auction.minimal_price == 100, "Auction should have 100 as minimals price")
  end

  def test_should_not_have_current_price
    assert(@auction.current_price == nil, "Auction should have no current price when created")
  end

  def test_should_have_increment
    assert(@auction.increment == 10, "Auction should have increment 10")
  end

  def test_should_have_end_time
    assert(@auction.end_time == @time, "Auction should have @time as start time")
  end

  def test_should_have_no_past_winners
    assert(@auction.past_winners.size == 0, "Should have no past winners when created")
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

  def test_creation_should_fail_when_time_is_in_past
    item = MockItem.new
    time = Time.now() - 1
    assert_raise(RuntimeError) { auction = Auction.create(item, 100, 10, time) }
  end

  def bid
    @user = MockUser.new
    @auction.bid(@user, 200)
  end

  def test_should_have_winner_after_first_bid
    bid
    assert(@auction.winner == @user, "Winner should be user that bidded")
  end

  def test_should_decrease_credits_of_winner
    bid
    assert(@user.credit == 400, "Should decrease money as high as bid(200) but was #{600 - @user.credit}")
  end

  def test_should_not_increment_start_price_after_first_bid
    bid
    assert(@auction.current_price == 100, "Price should be incremented after bid")
  end

  def test_should_not_be_editable_when_bids_are_set
    bid
    assert(!@auction.editable?,"Item should not be editable when bids are set")
  end

  def test_minimal_price_should_not_be_editable_when_bids_are_set
    bid
    assert_raise(RuntimeError) { @auction.minimal_price = 300 }
  end

  def test_increment_should_not_be_editable_when_bids_are_set
    bid
    assert_raise(RuntimeError) { @auction.increment = 20 }
  end

  def test_end_time_should_not_be_editable_when_bids_are_set
    bid
    assert_raise(RuntimeError) { @auction.end_time = Time.now }
  end

  def test_should_not_possible_to_bid_when_time_is_up
    @item = MockItem.new
    @time = Time.now() + 0.5
    @auction = Auction.create(@item, 100, 10, @time)
    sleep(0.5)

    assert(@auction.closed?, "Should not be possible to bit when time is up")
  end

  def test_should_sell_object_after_time_out_to_highest_bidder
    bid
    @auction.timed_out

    assert(@user.bought_item == @item, "User should have bought item")
  end

  def test_when_timed_out_should_get_money_back_to_buy_item_afterwards
    bid
    @auction.timed_out

    assert(@user.credit == 600, "User should have 600 credits but was #{@user.credit}")
  end

  def test_bid_should_fail_if_price_smaller_than_current_price
    @user = MockUser.new
    assert_raise(RuntimeError) { @auction.bid(@user, 90) }
  end

  def test_bid_should_fail_if_somebody_bid_already_same_price
    bid

    @user = MockUser.new
    assert_raise(RuntimeError) { @auction.bid(@user, 200) }
  end

  def test_bid_should_fail_if_auction_is_already_over
    @item = MockItem.new
    @time = Time.now() + 0.1
    @auction = Auction.create(@item, 100, 10, @time)
    sleep(0.2)

    @user = MockUser.new
    assert_raise(RuntimeError) { @auction.bid(@user, 400) }
  end

  def test_get_bid_of_should_return_nil_if_not_bidder
    bid

    not_bidder = MockUser.new
    assert_nil(@auction.get_bid_of(not_bidder), "Should return nil if user haven't bid on auction")
  end

  def test_get_bid_of_should_return_bid
    bid

    retrieved_bid = @auction.get_bid_of(@user)

    assert(retrieved_bid == 200, "Should return last bid of bidder (200 credits) but was #{retrieved_bid}")
  end

  def test_raising_his_own_bid_should_not_raise_current_price
    bid

    @auction.bid(@user, 300)
    assert(@auction.current_price == 100, "Price should not be raised when bidding on own bid")
  end

  def two_bidders
    @bidder_one = MockUser.new
    @auction.bid(@bidder_one, 200)

    @bidder_two = MockUser.new
    @auction.bid(@bidder_two, 300)
  end

  def test_should_set_bidder_with_higher_bid_as_winner
    two_bidders
    assert(@auction.winner == @bidder_two, "Should set bidder_two as winner but was #{@auction.winner}")
  end

  def test_should_set_price_an_increment_higher_than_bid_of_lower_bidder
    two_bidders
    assert(@auction.current_price == 210, "Should set bid to 210 but was #{@auction.current_price}")
  end

  def test_should_decrease_money_of_second_bidder
    two_bidders
    assert(@bidder_two.credit == 300, "Should decrease credits of bidder two as high as bid (300)")
  end

  def test_should_return_money_to_bidder_one
    two_bidders
    assert(@bidder_one.credit == 600, "Should return money when bidder one is not the winner anymore")
  end

  def test_should_set_one_past_winner_when_two_bidders
    two_bidders
    assert(@auction.past_winners.size == 1, "Should have one past winner")
  end

  def test_should_set_bidder_one_as_past_winner_when_two_bidders
    two_bidders
    assert(@auction.past_winners[0].agent == @bidder_one, "Should have bidder one as past winner")
  end

  def test_time_of_past_winner_should_be_close_to_now
    two_bidders
    assert_in_delta(Time.now.to_f, @auction.past_winners[0].time.to_f, 0.5, "Should be just now when last winner changed")
  end
end