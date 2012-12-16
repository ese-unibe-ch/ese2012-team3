module Market

  # This implements the credit locking used by an {Item}-{Auction}: An agent may not use the money hid bid if he is the winner the given auction.
  # and also used by offer: An agent may not use money he offered for something he wants to buy.
  class Safe

    attr_accessor_typesafe Agent,  :owner

    attr_accessor :savings # <tt>Numeric</tt>, the amount of credits in the safe.

    def initialize()
      self.savings = 0
      self.owner = nil
    end

    # @param [Agent] owner The agent that will put <tt>amount</tt> of his {Agent#credit credits} in the safe.
    #@param [Numeric] amount strictly positive
    def fill(owner, amount)
      fail "Safe already in use." unless self.owner.nil?

      self.owner = owner
      fail "Amount has to be set" if amount.nil?
      fail "Amount has to be greater than 0" if amount.to_i <= 0
      fail "Amount to fill in safe has to be greater or equal to the credits the user owns" if self.owner.credit.to_i < amount.to_i

      self.owner.credit -= amount
      self.savings = amount
    end

    # Give the owner back his credits and reset the safe.
    def return
      fail "Nobody owns this safe" if owner.nil?

      owner.credit += self.savings
      self.savings = 0
      self.owner = nil
    end
  end
end
