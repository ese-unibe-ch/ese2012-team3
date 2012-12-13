module Market

  # A User is the only type of {Agent} that can follow other agents. It can also join {Organization Organizations} and have a wishlist.
  #
  # * Users have a name.
  # * Users have an amount of credits.
  # * A new user has 100 credits unless specified otherwise.
  # * A user can add a new item to the system with a name and a price; the item is originally inactive.
  # A user can buy active items of another user (inactive items can't be bought).
  # When a user buys an item, it becomes the owner; credit are transferred accordingly;
  # immediately after the trade, the item is inactive. The transaction fails if the buyer has not enough credits.
  # A user provides a method that lists his/her active items to sell.
  class User < Agent

    attr_accessor_typesafe_not_nil String, :password

    attr_accessor :following # an <tt>Array</tt> of {Agent}s
    attr_accessor :logged_in # true/false
    attr_accessor :last_action_time # a <tt>Time</tt> object
    attr_accessor :last_action_url # a <tt>String</tt>

    @@user_id_counter = 1 # @internal_note cannot use @@users.size as user may be deleted
    @@users = []

    # constructor - initializes the user and gives a credit of 100 if nothing else is specified
    # @param [Hash] params dictionary of symbols (required), recognized keys:
    #   * <tt>:name => String</tt> (required)
    #   * <tt>:credit => Numeric</tt> defaults to 100
    #   * <tt>:password => String</tt> (required) -- must be strong (see PasswordCheck)
    #   * <tt>:about => String</tt>, supports markdown
    def self.init(params={})
      assert_kind_of(String, params[:name])
      fail "Username missing" unless params[:name] && params[:name].length > 0
      fail "User with given username already exists" if self.user_by_name(params[:name])
      user = self.new
      user.activities = []
      user.logged_in = false
      user.name = params[:name]
      user.credit = params[:credit] || 100
      user.about = params[:about] || ""
      PasswordCheck::ensure_password_strong(params[:password], params[:name], "")
      user.password = params[:password] || ""
      user.following = []
      user.wishlist = []
      user.image_file_name = nil
      @@users << user
      user.id = @@user_id_counter
      @@user_id_counter = @@user_id_counter + 1
      user
    end

    # @return the global user list
    def self.all
      @@users
    end

    # @return all user names
    def self.all_names
      names = []
      @@users.each do |user|
        names << user.name
      end
      names
    end

    def self.user_by_name(name)
      @@users.detect { |user| user.name == name }
    end

    def self.has_user_with_id?(id)
      return @@users.detect { |user| user.id == id.to_i } != nil
    end

    def self.user_by_id(id)
      user = @@users.detect { |user| user.id == id.to_i }
      if user == nil
         raise "no user found with id #{id}"
      end
      user
    end

    def self.delete_all
      while @@users.length > 0
        @@users[0].delete
      end
      @@user_id_counter = 0
    end

    def delete
      self.delete_as_agent
      @@users.delete(self)
    end

    def is_member_of?(organization)
      organization.has_member?(self)
    end

    # list organizations this user is member of
    # @see Market::Organization.organizations_by_user
    def list_organizations
      Organization.organizations_by_user(self)
    end

    # @return true if this user is admin of <i>any</i> of his organizations (that is, of any in {User#list_organizations})
    def is_admin?
      for org in self.list_organizations
        return true if org.is_admin?(self)
      end
    end

    def is_admin_of?(org)
      return org.is_admin?(self)
    end

    def self.all_outside_organization(org)
      all.select {|user| !user.is_member_of?(org)}
    end

    # @internal_note TODO move to a more appropriate place
    # @return the server route the the users profile page
    def profile_route
      "/profile/#{self.id}"
    end

    def self.total_user_credits
      sum = 0
      for user in @@users
         sum += user.credit
      end
      return sum
    end

    # toggles following the specified agent
    # @param follow [Agent]
    def follow(follow)
      unless self.following.include?(follow)
        self.following << follow
      else
        self.following.delete(follow)
      end
    end

    #collect all activities of followees
    def get_followees_activities
      activities = []
      for user in self.following do
        activities.concat(user.activities)
      end
      activities.sort! {|a,b| b.timestamp <=> a.timestamp}
    end

  end

end
