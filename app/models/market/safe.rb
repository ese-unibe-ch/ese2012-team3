module Market
  class Safe
    attr_accessor :savings, :owner

    def initialize
      self.savings = 0
      self.owner = nil
    end

    def fill(owner, amount)
      fail "Owner has to be set" if owner.nil?
      fail "Amount has to be set" if amount.nil?
      fail "Amount has to be greater than 0" if amount < 0
      fail "Amount to fill in safe has to be greater or equal to the credits the user owns" if owner.credits < amount
      fail "Safe already in use." unless self.owner.nil?

      owner.credits -= amount
      self.savings = amount
      self.owner = owner
    end

    def return
      fail "Nobody owns this safe" if owner.nil?

      owner.credits += self.savings
      self.savings = 0
      self.owner = nil
    end
  end
end