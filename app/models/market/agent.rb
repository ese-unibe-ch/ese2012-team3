# Abstract
module Market
  class Agent
    attr_accessor :name, :credit, :about, :id, :image_file_name,
                  :activities, :wishlist

    # increase the balance
    # @param [Numeric] amount - amount to be added
    def increase_credit(amount)
      self.credit += amount
    end

    # decrease the balance
    # @param [Numeric] amount - amount to be subtracted
    def decrease_credit(amount)
      fail "Not enough credit (#{self.credit}) to subtract #{amount}" unless self.credit >= amount
      self.credit -= amount
    end

    # add a specified item to the selling list
    # @param [Item] item - item to be added
    def add_item(item)
      item.owner = self
      item.activate
    end

    # buy a specified item from another user
    # -> pay credits, change ownership, add item to user's list
    # @param [Item] item - item to be bought
    def buy_item(item)
      if(item == nil)
        raise "no item to buy given"
      end
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
      item.owner.remove_from_agent(item)
      item.owner = self
      item.inactivate
    end

    # remove item from user's list and set the item's owner to nil
    # @param [Item] item - item to be removed
    def remove_from_agent(item)
      item.owner = nil
    end

    # add item to wishlist
    # currently the button is only displayed for organizations
    # @param [Item] item - item to be added to the wishlist
    def add_item_to_wishlist(item)
      wishlist << item unless wishlist.include?(item)
    end

    # remove item from wishlist
    # @param [Item] item - item to be removed from wishlist
    def remove_item_from_wishlist(item)
      wishlist.delete(item)
    end

    # @param [Activity] activity
    def add_activity(activity)
      self.activities.push(activity)
    end
  end
end
