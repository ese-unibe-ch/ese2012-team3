require "test/unit"

class TestSafe < Test::Unit::TestCase
  class MockUser
    attr_accessor :credits

    def initialize
      self.credits = 150
    end
  end

  def setup
    @safe = Safe.new
  end

  def fill_safe
    @user = MockUser.new
    @amount = 100

    @safe.fill(@user, @amount)
  end

  def test_should_have_no_owner_when_created
    assert(@safe.owner == nil, "After return there should be no owner no more")
  end

  def test_should_have_no_savings_when_created
    assert(@safe.savings == 0, "After return there should be no money in the safe")
  end

  def test_should_hold_money_when_filled
    fill_safe
    assert(@safe.savings == 100, "Should hold 100 credits")
  end

  def test_should_decrease_money_of_user_when_filled
    fill_safe
    assert(@user.credits == 50, "Should decrease money by 100")
  end

  def test_return_should_increase_money_of_user
    fill_safe
    @safe.return
    assert(@user.credits == 150, "Should increase money by 100")
  end

   def test_return_should_clear_user
     fill_safe
     @safe.return
     assert(@safe.owner == nil, "After return there should be no owner no more")
   end

   def test_return_should_set_credits_to_zero
     fill_safe
     @safe.return
     assert(@safe.savings == 0, "After return there should be no money in the safe")
   end

   def test_should_not_possible_to_fill_when_in_use
     fill_safe

     assert_raise(RuntimeError) { @safe.fill(MockUser.new, 100) }
   end
end