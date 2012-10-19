module Market

  class Item
    # Items have a name
    # Items have a price.
    # An item can be active or inactive.
    # An item has an owner.

    attr_accessor :id,
                  :name,
                  :price, # positive number
                  :owner, # an Agent
                  :active, # Boolean
                  :comments, # List    of Comment objects
                  :about,    # TODO share common functionality with agent?
                  :image_file_name

    @@item_id_counter = 0
    @@items = []

    # constructor - give a name to the item and set a specified price
    # @param [Object] params - dictionary of symbols. Recognized: :name, :price, :active, :owner, :about
    def self.init(params={})
      item = self.new
      item.id = @@item_id_counter
      item.name = params[:name] || "default item"
      item.price = params[:price] || 0
      item.active = params[:active] || false
      item.owner = params[:owner]
      item.about = params[:about] || ""
      item.comments = []
      @@items << item
      @@item_id_counter += 1
      item
    end

    # activate the item
    def activate
      self.active = true
    end

    # deactivate the item
    def inactivate
      self.active = false
    end

    def active?
      :active?
    end

    def to_s
      "#{self.name} (#{self.price})"
    end

    def self.by_id id
      @@items.detect{ |item| item.id.to_i == id }
    end

    def self.all
      @@items
    end

    # list of all active item
    def self.active_items
      @@items.select { |item| item.active }
    end

    # list of user's items to sell
    def self.sell_items_by_agent (user)
      @@items.select { |item| item.active && item.owner == user }
    end

    # list of user's items
    def self.items_by_agent(user)
      @@items.select { |item| item.owner == user }
    end

    def self.delete_all
      @@items = []
    end

    def delete
      @@items.delete(self)
    end

  end
end
