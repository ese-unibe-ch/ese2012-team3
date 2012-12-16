class ItemTest < Test::Unit::TestCase
  def test_has_text_and_creator
    user = User.init(:name => "user1", :password => "Zz!45678")
    t = "test comment"
    cmt = Comment.new(:text => t, :creator => user)

    assert(cmt.creator == user, "Comment has no creator")
    assert(cmt.text == t, "Comment has no text")
  end

  def test_creator_required
    assert_raise RuntimeError do
      cmt = Comment.new()
    end
  end
end
