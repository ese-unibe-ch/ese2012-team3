# Abstract
module Market

  # Agents are entities that can be active in the market system.
  # They can own {Market::Items} and generate {Market::Activity} that are seen by followers (currently, only {User}s can follow someone).
  # They have a profile picture, a name and further information.
  class Agent

    @@items_sold = 0  # <tt>Numeric</tt>, counter for statistics
    @@money_spent = 0 # <tt>Numeric</tt>, counter for statistics

    attr_accessor_typesafe_not_nil String, :name
    attr_accessor_typesafe_not_nil String, :about # Markdown allowed
    attr_accessor_typesafe String, :image_file_name # Relative to the public folder

    attr_accessor :credit # <tt>Numeric</tt>
    attr_accessor :id     # <tt>Numeric</tt>
    attr_accessor :activities # <tt>Array</tt>
    attr_accessor :wishlist   # <tt>Array</tt>

    # @param [Numeric] amount amount to be added
    def increase_credit(amount)
      self.credit += amount
    end

    # @param [Numeric] amount amount to be subtracted
    def decrease_credit(amount)
      fail "Not enough credit (#{self.credit}) to subtract #{amount}" unless self.credit >= amount
      self.credit -= amount
    end

    # add a specified item to the selling list
    # @param [Item] item item to be added
    def add_item(item)
      assert_kind_of(Item, item)
      item.owner = self
      item.activate
    end

    # Buy a specified item from another user.
    # That means pay credits, change ownership, add item to user's list.
    # @param [Item] item item to be bought
    def buy_item(item)
      assert_kind_of(Item, item)

      if(item.owner == nil)
        raise "item #{item} has no owner"
      end
      if(self.credit < item.price)
        raise "cannot afford item #{item}"
      end
      if(!item.active)
        raise "item #{item} is inactive"
      end
      if(item.owner == self)
        raise "cannot buy item #{item} from myself"
      end
      self.decrease_credit(item.price)
      item.owner.increase_credit(item.price)
      item.owner = self
      @@items_sold += 1
      @@money_spent += item.price
      item.change_status
    end

    # Toggles in-wishlist state of an {Item}.
    # @param [Item] item
    def change_wishlist(item)
      assert_kind_of(Item, item)
      if wishlist.include?(item)
        wishlist.delete(item)
      else
        wishlist << item
      end
    end

    # @param [Activity] activity
    def add_activity(activity)
      assert_kind_of(Activity, activity)
      raise "cannot add same activity multiple times" if self.activities.include?(activity)
      self.activities.push(activity)
    end

    # null implementation, to be implemented by {Organization}
    # @params [Activity] activity
    def add_orgactivity(activity)

    end

    # null implementation, to be implemented by {User} (an {Organization} doesn't have cannot follow anybody)
    def get_followees_activities
      []
    end

    # @internal_note TODO move to a more appropriate place - however if we do, we will have to use ugly kind_of?
    # null implementation, implemented in {User} and {Organization}
    # @return the server route the the user's/organization's profile page
    def profile_route
      "/"
    end

    # Removes all {Item Items} of this agent and all memberships in {Organization Organizations} he joined plus deletes his picture via {#delete_image_file}.
    def delete_as_agent
      for item in Item.items_by_agent(self)
        item.delete
      end

      for org in Organization.organizations_by_user(self)
        org.remove_member(self)
      end
      self.delete_image_file
    end

    # internal_note We could store images on the application level, but then we'd have to handle Agent deletion over that as well...
    def delete_image_file
      delete_public_file(self.image_file_name)
      self.image_file_name = nil
    end

    # Amount of items sold
    # Statistics
    def self.items_sold
      return @@items_sold
    end

    # Statistics
    def self.money_spent
      return @@money_spent
    end

    #noop implementation, only organisations have orgactivities
    #but this here allows the controllers to be agnostic about agent type
    def add_orgactivity(orgactivity)
    end

  end
end
