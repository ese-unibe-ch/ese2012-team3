class Module

  #
  # Defines an attribute accessor where attributes are
  # only accessible when the given object is editable.
  #
  # An object using this attribute accessor has to
  # implement a method #editable?
  #

  def attr_accessor_only_if_editable(*args)
    args.each do |attr_name|
      attr_name = attr_name.to_s

      #getter
      self.class_eval %Q{
        def #{attr_name}
          @#{attr_name}
        end
      }

      #setter
      self.class_eval %Q{
        def #{attr_name}=(val)
          fail "Not editable!" unless self.editable?

          # set the value itself
          @#{attr_name}=val
        end
      }
    end
  end
end

module Market
  class Auction
    attr_accessor_only_if_editable :minimal_price, :increment
    attr_accessor :event, :item
    attr_reader :winner, :current_price, :item, :event, :safe, :bids

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
        fail "Safe should have same value as price if there are bidders" unless self.safe.savings == self.current_price
        fail "Safe should always have winner as owner" unless self.safe.owner == self.winner
      end
    end

    def initialize
      @bids = Hash.new
      @winner = nil
      @safe = Safe.new
      @current_price = nil
    end

    def price
      @current_price.nil? ? self.minimal_price : @current_price
    end

    def dismiss
      safe.return unless @winner.nil?
      event.unschedule
    end

    def self.create(item, price, increment, time)
      fail "Can't set an auction that starts in past" if time < Time.now
      fail "Price should not be negative" if price < 0
      fail "Increment should be greater than 0" if increment <= 0
      fail "Item should not be nil" if item.nil?

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

    def offer(agent, price)
      fail "Offer must be equal or smaller than credits owned by agent" if agent.credits < price
      if (self.current_price.nil?)
        fail "Offer must be equal or bigger than the minimal price" if price < self.minimal_price
      else
        fail "Offer must be equal or bigger than the current price" if price < self.current_price
      end
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

      current_winner = bids[prices[0]]

      #Set current price
      if (prices.size > 1)
        @current_price = prices[1]+increment
      else
        @current_price = self.minimal_price
      end

      #Hold back money of winner
      unless self.winner == current_winner
        self.safe.return unless self.winner.nil?

        self.safe.fill(current_winner, self.current_price)
      end

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
      if @winner.nil?
        self.item.inactivate
      else
        safe.return
        @winner.buy_item(self.item)
      end

      item.auction = nil
    end
  end
end