module Market
  # Purpose? This implements the credit locking?
  class Safe

    attr_accessor_typesafe Agent,  :owner

    attr_accessor :savings

    def initialize
      self.savings = 0
      self.owner = nil
    end

    def fill(owner, amount)
      fail "Safe already in use." unless self.owner.nil?

      self.owner = owner
      fail "Amount has to be set" if amount.nil?
      fail "Amount has to be greater than 0" if amount.to_i < 0
      fail "Amount to fill in safe has to be greater or equal to the credits the user owns" if self.owner.credit.to_i < amount.to_i

      self.owner.credit -= amount
      self.savings = amount
    end

    # this does what?
    def return
      fail "Nobody owns this safe" if owner.nil?

      owner.credit += self.savings
      self.savings = 0
      self.owner = nil
    end
  end
end