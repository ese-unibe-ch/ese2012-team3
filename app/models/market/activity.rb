module Market

  # An activity consists of a message, a type and a timestamp.
  # It is to be generated on specific events - e.g. a user commenting on an item - for logging purposes.
  class Activity
    @@activity_types = [:comment, :follow, :activate, :buy, :createitem]

    attr_reader :creator # The agent that caused this activity to be created. Always a user for activities within organization orgactivities
    attr_reader :timestamp # Time.now at init (use timestamp.to_i for comparisons (?))
    attr_reader :type # any of :comment, :follow, :activate, :buy, :createitem  - last two only used within orgactivities

    # The complete message, as a {LocalizedMessage}.
    # All strings can use markdown.
    # @internal_note TODO Store more information and generate message later on?
    #   Problem: Will have to store old item names, price, links to users which might not exist anymore... -->
    attr_reader :message

    # Called by ruby on new
    # @param params: hash, recognized identifiers:
    #   * <tt>:creator</tt> required, a {Market::Agent}
    #   * <tt>:type</tt> required, any of {@@activity_types}
    #   * <tt>:message</tt> empty by default
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

    # See {Activity#initialize}
    def self.init(params={})
      return self.new(params)
    end

    # @param creator [Market::Agent]
    # @param item [Market::Item]
    def self.new_activate_activity(creator, item)
      Activity.init({:creator => creator,
                     :type => :activate,
                     :message => LocalizedMessage.new([
                                                          LocalizedMessage::LangKey.new("ACTIVATED_ITEM"),
                                                          " ",
                                                          item.name.clone # clone to ensure this history stays intact after the item is deleted
                                                      ])
          })
    end

    # @param creator [Market::Agent]
    # @param item [Market::Item]
    def self.new_buy_activity(creator, item)
      Activity.init({:creator => creator,
                     :type => :buy,
                     :message => LocalizedMessage.new([
                                                          LocalizedMessage::LangKey.new("BOUGHT_ITEM"),
                                                          " ",
                                                          item.name.clone
                                                      ])
                    })
    end

    # @param creator [Market::Agent]
    # @param item [Market::Item]
    def self.new_createitem_activity(creator, item)
      Activity.init({:creator => creator,
                     :type => :createitem,
                     :message => LocalizedMessage.new([
                                                          LocalizedMessage::LangKey.new("CREATED_ITEM"),
                                                          " ",
                                                          item.name.clone
                                                      ])
                    })
    end

    # @param creator [Market::Agent]
    # @param item [Market::Item]
    def self.new_comment_activity(creator, item)
      Activity.init({:creator => creator,
                     :type => :comment,
                     :message => LocalizedMessage.new([
                                                          LocalizedMessage::LangKey.new("COMMENTED_ON"),
                                                          " ",
                                                          item.name.clone
                                                      ])
                    })
    end

    # @param creator [Market::Agent]
    # @param follow [Market::Agent]
    def self.new_follow_activity(creator, follow)
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


end
