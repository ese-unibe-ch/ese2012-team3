module Market
  class Activity
    @@activity_types = [:comment, :follow, :activate, :buy, :createitem]

    attr_reader :creator, # The agent that caused this activity to be created. Always a user for activities within organization orgactivities
                :timestamp, # Time.now at init (use timestamp.to_i for comparisons (?))
                :type, # any of :comment, :follow, :activate, :buy, :createitem  - last two only used within orgactivities
                :message # the complete message, as a LocalizedMessage
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
      assert_kind_of(LocalizedMessage, params[:message]) if params[:message]

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

  def new_activate_activity(creator, item)
    Activity.init({:creator => creator,
                   :type => :activate,
                   :message => LocalizedMessage.new([
                                                        LocalizedMessage::LangKey.new("ACTIVATED_ITEM"),
                                                        " #{item.name}"
                                                    ])
        })
  end

  def new_buy_activity(creator, item)
    Activity.init({:creator => creator,
                   :type => :buy,
                   :message => LocalizedMessage.new([
                                                        LocalizedMessage::LangKey.new("BOUGHT_ITEM"),
                                                        " #{item.name}"
                                                    ])
                  })
  end

  def new_createitem_activity(creator, item)
    Activity.init({:creator => creator,
                   :type => :createitem,
                   :message => LocalizedMessage.new([
                                                        LocalizedMessage::LangKey.new("CREATED_ITEM"),
                                                        " #{item.name}"
                                                    ])
                  })
  end

  def new_comment_activity(creator, item)
    Activity.init({:creator => creator,
                   :type => :comment,
                   :message => LocalizedMessage.new([
                                                        LocalizedMessage::LangKey.new("COMMENTED_ON"),
                                                        " #{item.name}"
                                                    ])
                  })
  end

  def new_follow_activity(creator, follow)
    Activity.init({:creator => creator,
                   :type => :follow,
                   :message =>
                       LocalizedMessage.new([
                                                creator.following.include?(follow) ? LocalizedMessage::LangKey.new("NO_LONGER_FOLLOWS") : LocalizedMessage::LangKey.new("FOLLOWS"),
                                                " #{follow.name}"
                                            ])
                  })
  end



end