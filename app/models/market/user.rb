module Market

  class User < Agent
    # Users have a name.
    # Users have an amount of credits.
    # A new user has originally 100 credit.

    # A user can add a new item to the system with a name and a price; the item is originally inactive.
    # A user can buy active items of another user (inactive items can't be bought).
    # When a user buys an item, it becomes the owner; credit are transferred accordingly;
    # immediately after the trade, the item is inactive. The transaction fails if the buyer has not enough credits.
    # A user provides a method that lists his/her active items to sell.

    attr_accessor_typesafe_not_nil String, :password

    attr_accessor :following # a list of agents

    @@user_id_counter = 1 # cannot use @@users.size as user may be deleted
    @@users = []

    # constructor - initializes the user and gives a credit of 100 if nothing else is specified
    # @param [Object] params - dictionary of symbols, recognized: :name, :credit, :password -- must be strong (see PasswordCheck), :about
    # required: :name
    def self.init(params={})
      assert_kind_of(String, params[:name])
      fail "Username missing" unless params[:name] && params[:name].length > 0
      fail "User with given username already exists" if self.user_by_name(params[:name])
      user = self.new
      user.activities = []
      user.name = params[:name]
      user.credit = params[:credit] || 100
      user.about = params[:about] || ""
      PasswordCheck::ensure_password_strong(params[:password], params[:name], "")
      user.password = params[:password] || ""
      user.following = []
      user.wishlist = []
      @@users << user
      user.id = @@user_id_counter
      @@user_id_counter = @@user_id_counter + 1
      user
    end

    # returns the global user list
    def self.all
      @@users
    end

    # returns all user names
    def self.all_names
      names = []
      @@users.each do |user|
        names << user.name
      end
      names
    end

    # returns a user with the given name
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

    # TODO "I can delete my account only if there's a second admin" (in every org I work for)
    def delete
      self.delete_as_agent
      @@users.delete(self)
    end

    def is_member_of?(organization)
      organization.has_member?(self)
    end

    def list_organizations
      Organization.organizations_by_user(self)
    end

    # returns true if this user is admin of any of his organizations
    def is_admin?
      for org in self.list_organizations
        return true if org.is_admin?(self)
      end
    end

    def is_admin_of?(org)
      return org.is_admin?(self)
    end

    # TODO move to a more appropriate place
    def profile_route
      "/profile/#{self.id}"
    end



    # toggles following the specified agent
    def follow(follow)
      unless self.following.include?(follow)
        self.following << follow
      else
        self.following.delete(follow)
      end
    end

  end

end
