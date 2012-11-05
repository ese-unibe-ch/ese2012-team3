require 'rubygems'
require 'rufus/scheduler'

module Market
  class TimedEvent
    attr_accessor :time, :subscribers, :scheduler, :timed_out

    def self.create(object_to_time, time)
      fail "Object to be called should not be nil" if object_to_time.nil?
      fail "Time should not be nil" if time.nil?
      fail "Should have method #timed_out implemented" unless object_to_time.respond_to?(:timed_out)
      fail "Time should not be in past" if time < Time.now

      event = TimedEvent.new

      event.scheduler = Rufus::Scheduler.start_new
      event.time = time
      event.timed_out = false
      event.subscribers = Array.new
      event.subscribers.push(object_to_time)

      time = Rufus.to_datetime time

      event.scheduler.at time.to_s do
        event.timed_out = true
        event.subscribers.each { |object| object.timed_out }
      end

      event
    end

    def subscribe(object_to_time)
      self.subscribers.push(object_to_time)
    end
  end
end