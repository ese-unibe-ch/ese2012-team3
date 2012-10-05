require_relative '../passwordcheck'

module Market

  class User
    # Users have a name.
    # Users have an amount of credits.
    # A new user has originally 100 credit.

    # A user can add a new item to the system with a name and a price; the item is originally inactive.
    # A user can buy active items of another user (inactive items can't be bought).
    # When a user buys an item, it becomes the owner; credit are transferred accordingly;
    # immediately after the trade, the item is inactive. The transaction fails if the buyer has not enough credits.
    # A user provides a method that lists his/her active items to sell.

    attr_accessor :name, :credit, :items, :password

    @@users = []

    # constructor - initializes the user and gives a credit of 100 if nothing else is specified
    # @param [Object] params - dictionary of symbols, recognized: :name, :credit, :password -- must be strong (see PasswordCheck)
    def self.init(params={})
      user = self.new
      user.name = params[:name] || "default user"
      user.credit = params[:credit] || 100
      PasswordCheck::ensure_password_strong(params[:password], params[:name], "")
      user.password = params[:password] || ""
      @@users << user
      user
    end

    # initialize the items array
    def initialize
      self.items = []
    end

    # returns the global user list
    def self.all
      @@users
    end

    # returns all user names
    def self.allNames
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

    # returns an item with the given name
    def item_by_id(id)
      self.items.detect { |item| item.id.to_i == id }
    end

    # increase the balance
    # @param [Numeric] amount - amount to be added
    def increase_credit(amount)
      self.credit += amount
    end

    # decrease the balance
    # @param [Numeric] amount - amount to be subtracted
    def decrease_credit(amount)
      self.credit -= amount
    end

    # add a specified item to the selling list
    # @param [Item] item - item to be added
    def add_item(item)
      item.owner = self
      item.activate
      self.items << item unless self.items.include?(item)
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
      item.owner.remove_from_user(item)
      item.owner = self
      item.inactivate
      self.items << item
    end

    # remove item from user's list and set the item's owner to nil
    # @param [Item] item - item to be removed
    def remove_from_user(item)
      self.items.delete(item)
      item.owner = nil
    end

    # list of user's items to sell
    def sell_items
      self.items.select { |item| item.active }
    end
  end

end
