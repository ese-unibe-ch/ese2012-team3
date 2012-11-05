class TestTimedEvent < Test::Unit::TestCase
  class Mock
    @timed_out = false

    def timed_out
      @timed_out = true
    end

    def timed_out?
      @timed_out
    end
  end

  def create_timed_event
    @mock = Mock.new
    @time = Time.now + 0.5
    @event = TimedEvent.create(@mock, @time)
  end

  def test_should_hold_time
    create_timed_event

    assert(@event.time == @time, "Should hold same time as set")
  end

  def test_should_call_timed_out
    create_timed_event

    sleep(0.5)
    assert(@mock.timed_out?, "#timed_out should have been called!")
  end

  def test_should_call_timed_out_on_all_subscribe_objects
    create_timed_event

    mock2 = Mock.new
    @event.subscribe(mock2)

    sleep(1.5)
    assert(@mock.timed_out?, "#timed_out should have been called for object one!")
    assert(mock2.timed_out?, "#timed_out should have been called for object two!")
  end
end