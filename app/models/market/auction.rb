
module Market

  # An auction is the handling object for the special item state "auction", it which it cannot be bought directly but is
  # sold to the highest bidder after the timeout.
  class Auction

    @@auctions_finished = 0 # for statistics
    @@bids_made = 0         # for statistics

    # statistics
    def self.bids_made
      return @@bids_made
    end
    # statistics
    def self.auctions_finished
      return @@auctions_finished
    end

    attr_accessor_only_if_editable :minimal_price, :increment
    attr_accessor :event # the {TimedEvent} that causes the auction to end

    attr_accessor_typesafe_not_nil Item,  :item
    attr_accessor_typesafe         Agent, :winner

    attr_reader :current_price # <tt>Numeric</tt>, positive
    attr_reader :safe # the {Safe} locking the currently winning (winner) {Agent}'s credits he bid
    attr_reader :bids # A hase bid value (<tt>Numeric</tt>) to {Agent}
    attr_reader :past_winners # an <tt>Array</tt> of {PastWinner}s

    # stores an agent and his bid and the time of the bid
    class PastWinner
      attr_accessor :agent, :time, :price
      def self.create(agent, time, price)
        past_winner = PastWinner.new
        past_winner.agent = agent
        past_winner.time = time
        past_winner.price = price

        past_winner
      end
    end

    def invariant
      fail "Auction should always be closed when time is over" if self.end_time < Time.now && !self.closed?
      fail "Auction should always be open when time is still running" if self.end_time >= Time.now && self.closed?
      fail "Price should not be negative" if self.minimal_price < 0
      fail "Increment should be greater than 0" if self.increment <= 0
      fail "Item should not be nil" if self.item.nil?
      fail "Item should be active when not closed" unless !self.item.active? || !self.closed?
      fail "Item should be inactive when time is over" unless self.item.active? || self.closed?
      fail "Should always hold a timed event" if self.event.nil?

      if (self.bids.size > 0)
        fail "Should have current price if there are bidders" if self.current_price.nil?
        fail "Current price should be positive" if self.current_price < 0
        fail "Should not be editable when there are bids" if self.editable?
        fail "Safe should have same value as highest bid if there are bidders" unless self.safe.savings == self.highest_bid
        fail "Safe should always have winner as owner" unless self.safe.owner == self.winner
      end
    end

    def initialize
      @bids = Hash.new
      @winner = nil
      @safe = Safe.new
      @current_price = nil
      @past_winners = Array.new
    end

    def price
      @current_price.nil? ? self.minimal_price : @current_price
    end

    def dismiss
      safe.return unless @winner.nil?
      event.unschedule
      self.item.auction = nil
    end

    def self.create(item, price, increment, time)
      fail "Can't set an auction that starts in past" if time < Time.now
      fail "Price should not be negative" if price < 0
      fail "Increment should be greater than 0" if increment <= 0
      assert_kind_of(Item, item)

      auction = Auction.new

      auction.event = TimedEvent.create(auction, time)

      item.activate
      auction.item = item
      auction.minimal_price = price
      auction.increment = increment

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
    # Stops old TimedEvent and starts a new one
    #

    def end_time= (time)
      assert_kind_of(Item, item)
      fail "Bids are set. Not editable anymore" unless self.editable?

      self.event = TimedEvent.create(self, time)
    end

    #
    # Should be editable when no bids are set
    #

    def editable?
      @bids.size == 0
    end

    #
    # Should set bid for a specific user
    #
    # Bids that don't fit with increment are rounded
    # down.
    #

    def bid(agent, price)
      fail "This auction is closed" if closed?
      fail "Offer must be equal or smaller than credits owned by agent" if agent.credit.to_i < price.to_i
      if (self.current_price.nil?)
        fail "Offer must be equal or bigger than the minimal price" if price.to_i < self.minimal_price.to_i
      else
        fail "Offer must be equal or bigger than the current price" if price.to_i < self.current_price.to_i
      end

      #round = (price.to_i - minimal_price.to_i) % increment.to_i
      price = price.to_i #- round.to_i     # What about this rounding? you never mention this - removed MX  (caused bug "This offer already exists"" with 234 min price, 1 bid at 238, increment 4 -> new bid 239...)

      fail "This offer already exists" if bids.key?(price)

      remove_previous_bids_of(agent)
      bids[price] = agent
      @@bids_made += 1
      determine_winner

      self.invariant
    end

    #
    # Gets current bid (in credits) of an agent
    # Returns nil if agent didn't bid on this auction.
    #
    # bidder : agent looking for his bid
    #

    def get_bid_of(bidder)
      self.bids.each do |price, agent|
        return price if (agent == bidder)
      end

      nil
    end

    #
    # Removes all previous bids of this agent
    #

    def remove_previous_bids_of(agent_to_remove)
      self.bids.delete_if do |price, agent|
        agent == agent_to_remove
      end
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

      current_winner = bids[prices[0]]
      previous_bid = current_price

      #Set current price
      if (prices.size > 1)
        @current_price = prices[1].to_i+increment.to_i
      else
        @current_price = self.minimal_price.to_i
      end


      unless (self.winner == current_winner)
        #Sets old winner as past winner
        @past_winners.push(PastWinner.create(self.winner, Time.now, previous_bid)) unless (self.winner.nil?)

        #send mail to previous winner
        SimpleEmailClient.setup.send_email(@winner.name,"Auction Update","You got outbid on #{@item.name}") unless (@winner.nil?)
      end

      #Hold back money of winner
      self.safe.return unless self.winner.nil?
      self.safe.fill(current_winner, prices[0])

      #Set winner
      @winner = current_winner
    end

    #
    # Winner buys item after the auction timed out and resets the
    # the auction object to nil in item
    #
    # If there is no winner the item is just deactivated and
    # the auction object is set to nil
    #

    def timed_out
      self.item.auction = nil

      if @winner.nil?
        self.item.inactivate
      else
        safe.return
        self.item.price = current_price
        SimpleEmailClient.setup.send_email(@winner.name,"Auction Update","You won #{@item.name} in an auction")
        @winner.buy_item(self.item)
        @@auctions_finished +=1
      end
    end

    def minimal_bid
      if current_price.nil?
       value = minimal_price.to_i + increment.to_i
      else
       value = current_price.to_i + increment.to_i
      end
      value
    end

    def already_bid?(price)
      bids.key?(price)
    end

    def valid_bid?(price)
      if current_price.to_i + increment.to_i <= price.to_i
        true
      else
        false
     end

    end

    def highest_bid
      bids.keys.sort!.reverse![0]
    end
  end
end