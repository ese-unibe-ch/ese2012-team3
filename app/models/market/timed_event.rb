module Market

  # Implements the timeout of an {Auction}. Can have subscribers that must implement <tt>timed_out</tt> which will be called when the time specified is reached.
  class TimedEvent

    attr_accessor :time # a <tt>Time</tt> object specifing the time when this ends
    attr_accessor :subscribers # an <tt>Array</tt> of objects. Must implement timed_out, which will be called when the time is over
    attr_accessor :scheduler  # the <tt>Rufus::Scheduler</tt> used to create and handle timed events
    attr_accessor :timed_out # whether this event is timed out <tt>Boolean</tt>
    attr_accessor :job # the internal job (a function) to be executed when the timer runs out.

    # @param subscriber must implement "timed_out", called when timer runs out
    # @param time [Time]
    def self.create(subscriber, time)
      assert_kind_of(Time, time)
      fail "Time should not be in past" if time < Time.now

      event = TimedEvent.new

      event.scheduler = Rufus::Scheduler.start_new
      event.time = time
      event.timed_out = false
      event.subscribers = Array.new
      event.subscribe(subscriber)

      time = Rufus.to_datetime time

      event.job = event.scheduler.at time.to_s do
        event.timed_out = true
        event.subscribers.each { |object| object.timed_out }
      end

      event
    end

    # @internal_note Curently, only the Acution object itself subscribes to this
    # @param subscriber must implement "timed_out", called when timer runs out
    def subscribe(subscriber)
      fail "Object to be called should not be nil" if subscriber.nil?
      fail "Should have method #timed_out implemented" unless subscriber.respond_to?(:timed_out)
      self.subscribers.push(subscriber)
    end

    # Change the end time
    def reschedule(time)
      assert_kind_of(Time, time)
      fail "Time should not be in past" if time < Time.now

      time = Rufus.to_datetime time

      self.job.unschedule

      self.job = self.scheduler.at time.to_s do
        self.timed_out = true
        self.subscribers.each { |object| object.timed_out }
      end
    end

    # Reset (remove timer)
    def unschedule
      self.job.unschedule
    end
  end
end