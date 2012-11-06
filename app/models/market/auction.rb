module Market
  class Auction
    attr_accessor :price, :item, :increment, :winner, :bids, :event

    def invariant
      fail "Auction should always be closed when time is over" if self.end_time < Time.now && !self.closed?
      fail "Auction should always be open when time is still running" if self.end_time >= Time.now && self.closed?
      fail "Price should not be negative" if self.price < 0
      fail "Increment should be greater than 0" if self.increment <= 0
      fail "Item should not be nil" if self.item.nil?
      fail "Should always hold a timed event" if self.event.nil?
      fail "Should not be editable when there are bids" if self.bids.size > 0 && self.editable?
    end

    def self.create(item, price, increment, time)
      fail "Can't set an auction that starts in past" if time < Time.now
      fail "Price should not be negative" if price < 0
      fail "Increment should be greater than 0" if increment <= 0
      fail "Item should not be nil" if item.nil?

      auction = Auction.new
      auction.event = TimedEvent.create(auction, time)

      auction.item = item
      auction.price = price
      auction.increment = increment
      auction.winner = nil
      auction.bids = Hash.new

      auction.invariant

      auction
    end

    #
    # Returns time hold by TimedEvent
    #

    def end_time
      self.event.time
    end

    #
    # Should be editable when no bids are set
    #

    def editable?
      bids.size == 0
    end

    #
    # Should set bid for a specific user
    #

    def offer(agent, price)
      fail "Offer must be equal or bigger than the actual price" if price < self.price
      fail "This offer already exists" if bids.key?(price)
      fail "This auction is closed" if closed?

      bids[price] = agent

      determine_winner

      self.invariant
    end

    #
    # Should be closed after time is up
    #

    def closed?
      self.end_time < Time.now
    end

    #
    # Checks and sets current winner of this auction. This
    # Method should always be called when new bids arrive
    # or old bids are changed.
    #
    # Sorts bidders by price. Bidder with highest offer
    # is winner. Price is set an increment higher than
    # offer of bidder with second highest offer.
    #

    def determine_winner
      fail "You can only determine a winner if there are bids" if bids.size == 0

      prices = bids.keys.sort!.reverse!

      if (prices.size > 1)
        self.price = prices[1]+increment
      end

      self.winner = bids[prices[0]]
    end

    #
    # Winner buys item after the auction timed out
    #

    def timed_out
      unless (winner.nil?)
        winner.buy_item(self.item)
      end
    end
  end
end