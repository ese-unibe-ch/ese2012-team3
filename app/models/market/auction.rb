module Market
  class Auction
    attr_accessor :price, :end_time, :item, :increment, :winner, :bids

    def self.create(item, price, increment, time)
      fail "Can't set an auction that starts in past" if time < Time.now

      auction = Auction.new
      auction.item = item
      auction.price = price
      auction.increment = increment
      auction.end_time = time
      auction.winner = nil
      auction.bids = Hash.new

      auction
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