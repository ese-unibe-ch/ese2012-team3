class TestTimedEvent < Test::Unit::TestCase
  class Mock
    attr_accessor :time

    def initialize
      @timed_out = false
    end

    def timed_out
      @timed_out = true
      self.time = Time.now
    end

    def timed_out?
      @timed_out
    end
  end

  def create_timed_event(args = {})
    @mock = Mock.new
    @start_time = Time.now
    @time = @start_time + (args[:time] || 0.5)
    @event = TimedEvent.create(@mock, @time)
  end

  def test_should_hold_time
    create_timed_event

    assert(@event.time == @time, "Should hold same time as set")
  end

  def test_should_call_timed_out
    create_timed_event

    sleep(0.8)
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

  def actual_passed_time
    act_passed = Time.now - @start_time
    puts("\nActual passed time: %10.3fs" % act_passed.to_f)
  end

  def passed_time_till_time_out
    passed = @mock.time - @start_time
    puts("\nPassed time till timeout: %10.3fs" % passed.to_f)
  end

  def should_have_passed_time_till_time_out
    should_be_passed = @time - @start_time
    puts("\nShould be passed time till timeout: %10.3fs" % should_be_passed.to_f)
  end

  def test_should_reschedule_event
    create_timed_event(:time => 0.2)

    @event.reschedule(@start_time+0.4)
    @time = @start_time + 0.4

    sleep(0.6)
    assert(@mock.timed_out?, "Should be timed out after 0.6sec")
    assert_in_delta(@time, @mock.time, 0.1, "Should be timed out at the right time with a delta of 0.1s")
  end
end