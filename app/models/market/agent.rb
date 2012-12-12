# Abstract
module Market

  # Agents are entities that can be active in the market system.
  # They can own {Market::Items} and generate {Market::Activity} that are seen by followers (currently, only {User}s can follow someone).
  # They have a profile picture, a name and further information.
  class Agent

    @@items_sold = 0  # for statistics
    @@money_spent = 0 # for statistics

    attr_accessor_typesafe_not_nil String, :name
    attr_accessor_typesafe_not_nil String, :about # Markdown allowed
    attr_accessor_typesafe String, :image_file_name

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
      item.inactivate
    end

    # currently the button is only displayed for {User}s
    # @param [Item] item item to be added to the wishlist
    def add_item_to_wishlist(item)
      assert_kind_of(Item, item)
      wishlist << item unless wishlist.include?(item)
    end

    # @param [Item] item item to be removed from wishlist
    def remove_item_from_wishlist(item)
      assert_kind_of(Item, item)
      wishlist.delete(item)
    end

    # @param [Activity] activity
    def add_activity(activity)
      assert_kind_of(Activity, activity)
      raise "cannot add same activity multiple times" if self.activities.include?(activity)
      self.activities.push(activity)
    end

    def get_followees_activities
      []
    end

    # Removes all items of this agent and all arganizations he joined plus deletes his picture.
    def delete_as_agent
      for item in Item.items_by_agent(self)
        item.delete
      end

      for org in Organization.organizations_by_user(self)
        org.remove_member(self)
      end
      self.delete_image_file
    end

    def delete_image_file
      delete_public_file(self.image_file_name)
      self.image_file_name = nil
    end


    def self.items_sold
      return @@items_sold
    end

    def self.money_spent
      return @@money_spent
    end
  end
end
