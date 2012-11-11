module Market
  #cr: A class description would be very nice, that tells in a sentence what this class is for.

  class Activity
    @@activity_types = [:comment, :follow, :activate, :buy, :createitem]

    attr_accessor :creator, # The agent that caused this activity to be created. Always a user for activities within organization orgactivities
                  :timestamp, # Time.now at init (use timestamp.to_i for comparisons (?))
                  :type, # any of :comment, :follow, :activate, :buy, :createitem  - last two only used within orgactivities
                  :message # the complete message, excluding the time and user, e.g. "activated the item ...", "bought the item ... for ... credits"
                  # Will be formatted to: On ..., :user.name ... :message    <-- can use markdown
                  # TODO Store more information and generate message later on?
                  # Problem: Will have to store old item names, price, links to users which might not exist anymore...

    # params: hash, recognized: :creator (required), :type (required), :message (empty by default)
    def self.init(params={})
      a = self.new
      fail "No activity creator agent supplied" unless params[:creator]
      fail "No activity type supplied" unless params[:type]
      fail "Invalid activity type" unless @@activity_types.include?(params[:type])
      a.creator = params[:creator]
      a.type = params[:type]
      a.message = params[:message] || ""
      a.timestamp = Time.now
      a
    end


  end
end