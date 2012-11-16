module Market
  class Activity
    @@activity_types = [:comment, :follow, :activate, :buy, :createitem]

    attr_reader :creator, # The agent that caused this activity to be created. Always a user for activities within organization orgactivities
                :timestamp, # Time.now at init (use timestamp.to_i for comparisons (?))
                :type, # any of :comment, :follow, :activate, :buy, :createitem  - last two only used within orgactivities
                :message # the complete message, excluding the time and user, e.g. "activated the item ...", "bought the item ... for ... credits"
                  # Will be formatted to: On ..., :user.name ... :message    <-- can use markdown
                  # TODO Store more information and generate message later on?
                  # Problem: Will have to store old item names, price, links to users which might not exist anymore...

    # called by ruby on new
    # params: hash, recognized: :creator (required), :type (required), :message (empty by default)
    def initialize(params={})
      fail "No activity creator agent supplied" unless params[:creator]
      fail "No activity type supplied" unless params[:type]
      fail "Invalid activity type" unless @@activity_types.include?(params[:type])
      assert_kind_of(Agent, params[:creator])
      assert_kind_of(String, params[:message]) if params[:message]

      @creator = params[:creator]
      @type = params[:type]
      @message = params[:message] || ""
      @timestamp = Time.now
    end

    # params: hash, recognized: :creator (required), :type (required), :message (empty by default)
    def self.init(params={})
      return self.new(params)
    end
  end
end