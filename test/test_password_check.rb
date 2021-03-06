class TestPasswordCheck  < Test::Unit::TestCase
  def test_not_strong_word
    assert_raise LocalizedMessage do
      PasswordCheck::ensure_password_strong("Hello2U!", "", "")
    end
  end

  def test_strong
    PasswordCheck::ensure_password_strong("H3ll0 2 U!", "SomeUser", "")
  end

  def test_not_strong_similar
    assert_raise LocalizedMessage do
      PasswordCheck::ensure_password_strong("H0 2 U!3ll", "", "3llziO?.")
    end
  end

  def test_not_strong_username
    assert_raise LocalizedMessage do
      PasswordCheck::ensure_password_strong("H3ll0 2 U!", "H3ll0", "")
    end
  end

  def test_significantly_different?
    assert(PasswordCheck::significantly_different?("H3ll0 2 U!", "Ax1301!3"))
    assert(!PasswordCheck::significantly_different?("H3ll0 2 U!", "H3ll0 2 ME!"))
    #maybe some more?
  end
end
