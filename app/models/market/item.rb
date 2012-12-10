module Market
  class Auction #:nodoc: all #dummy

  end

  # Items are the goods traded in this system.
  # Offers are special items that are promoted to real items when someone accepts the offer.
  # * Items have a name
  # * Items have a price.
  # * An item can be active or inactive.
  # * An item has an owner.
  class Item


    attr_accessor_typesafe_not_nil Agent,   :owner
    attr_accessor_typesafe_not_nil LocalizedLiteral,   :name    # Hash of Language prefix @LANGCODE (de, en, fr, jp) => String (internally converted to LocalizedLiteral)
    attr_accessor_typesafe_not_nil LocalizedLiteral,   :about # Hash of Language prefix @LANGCODE (de, en, fr, jp) => String

    attr_accessor_typesafe         Auction, :auction # nil signifies no auction
    attr_accessor_typesafe         String,  :image_file_name # nil signifies no image

    attr_accessor :id,
                  :active, # true or false
                  :price, # positive number
                  :comments, # List of Comment objects
                  :safe

    @@item_id_counter = 0
    @@items = []
    @@offers = [] # Offers are special items that are stored here instead of in @@items

    # constructor - give a name to the item and set a specified price
    # @param [Object] params - dictionary of symbols.
    # Recognized: <tt>:name, :price, :active, :owner, :about, :auction</tt>
    # Required: owner must be an Agent
    # if :name and :about are not hashes, we create them as "en" => string
    def self.init(params={})
      params[:name]  = {"en"=>params[:name]} if params[:name].kind_of? String
      params[:about] = {"en"=>params[:about]} if params[:about].kind_of? String

      item = self.new
      item.id = @@item_id_counter
      item.name = (params[:name].kind_of? LocalizedLiteral) ? params[:name] : LocalizedLiteral.new(params[:name] || {"en" => "default item"})
      item.price = params[:price] || 0
      item.active = params[:active] || false
      item.auction = params[:auction] || nil
      item.owner = params[:owner]
      item.about = (params[:about].kind_of? LocalizedLiteral) ? params[:about] :LocalizedLiteral.new(params[:about] || {"en" => ""})
      item.image_file_name = nil
      item.comments = []
      item.safe = params[:safe] || nil
      @@items << item unless params[:offer]
      @@item_id_counter += 1
      item
    end

    # activate the item
    def activate
      self.active = true
    end

    # Deactivates item and
    # dismissed an ongoing auction

    def inactivate
      self.active = false
      self.auction.dismiss unless auction.nil?
    end

    def active?
      :active?
    end

    def auction?
      ! self.auction.nil?
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
      while @@items.length > 0
        @@items[0].delete
      end
    end

    def delete
      delete_image_file
      @@items.delete(self)
      @@offers.delete(self)
    end

    def delete_image_file
      delete_public_file(self.image_file_name)
    end

    def add_comment new_comment
      comments << new_comment unless comments.include?(new_comment)
    end

    def self.find_item(pattern)
      @@items.select { |item|
        item.active && (item.name.include_i?(pattern) || item.about.include_i?(pattern))
      }
    end

    def is_offer?()
      Item.offer_by_id(self.id) == self
    end

    # same as {find_item} but for offers.
    def self.find_offer(pattern)
      @@offers.select { |offer| offer.name.include_i?(pattern) || offer.name.include_i?(pattern)}
    end

    def self.add_offer(offer)
      @@offers.push(offer)
    end

    def self.all_offers
      @@offers
    end

    def self.offer_by_id(id)
      @@offers.detect{ |offer| offer.id.to_i == id }
    end

    def self.transform_offer_to_item(offer)
      @@items.push(offer)
      @@offers.delete(offer)
    end
    
    def self.all_auctions
      @all_auctions = @@items.select{ |item| !item.auction.nil? }
    end
  end
end
