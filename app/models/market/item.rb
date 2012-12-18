module Market
  # @internal_note We need these for attr_accessor_typesafe(_not_nil)
  class Safe #:nodoc: all #dummy
  end

  class Auction #:nodoc: all #dummy
  end

  # Items are the goods traded in this system.
  # Offers are special items that are promoted to real items when someone accepts the offer.
  # * Items have a name
  # * Items have a price.
  # * An item can be active or inactive.
  # * An item has an owner.
  class Item


    attr_accessor_typesafe_not_nil Numeric, :id
    attr_accessor_typesafe_not_nil Agent,   :owner
    attr_accessor_typesafe_not_nil LocalizedLiteral,   :name    # Hash of Language prefix @LANGCODE (de, en, fr, jp) => String (internally converted to LocalizedLiteral)
    attr_accessor_typesafe_not_nil LocalizedLiteral,   :about # Hash of Language prefix @LANGCODE (de, en, fr, jp) => String

    attr_accessor_typesafe         Auction, :auction # nil signifies no auction
    attr_accessor_typesafe         String,  :image_file_name # nil signifies no image
    attr_accessor_typesafe         Safe,    :safe # nil signifies no offer (together with not being in @@offers)

    attr_reader :price # <tt>Numeric</tt>, positive

    attr_accessor :active,  # <tt>Boolean</tt> (true, false)
                  :comments # <tt>Array</tt> of {Comment} objects


    @@item_id_counter = 1
    @@items = []
    @@offers = [] # Offers are special items that are stored here instead of in @@items

    # constructor - give a name to the item and set a specified price
    # @param [Object] params - dictionary of symbols.
    #   Recognized: 
    #   * :name
    #   * :price
    #   * :active
    #   * :owner, an {Agent}, required
    #   * :about
    #   * :auction
    #   * :offer
    # 
    # if :name and :about are not hashes, we create them as "en" => string
    def self.init(params={})
      params[:name]  = {"en"=>params[:name]} if params[:name].kind_of? String
      params[:about] = {"en"=>params[:about]} if params[:about].kind_of? String

      item = self.new
      item.id = @@item_id_counter
      item.name = (params[:name].kind_of? LocalizedLiteral) ? params[:name] : LocalizedLiteral.new(params[:name] || {"en" => "default item"})
      item.set_price(params[:price] || 0)
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

    # Resets and recreates the safe if this is an offer.
    def set_price(price)
      @price = price
      if self.is_offer?
        self.safe.return
        self.safe.fill(self.owner, self.price)
      end
    end

    # Toggles the {#active} status of an item, dismissing ongoing auction in case there is one
    def change_status
      if self.active == true
        self.active = false
        self.auction.dismiss unless auction.nil?
      else
        self.active = true
      end
    end

    def activate
      self.active = true
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

    # @return list of user's items
    def self.items_by_agent(user)
      @@items.select { |item| item.owner == user }
    end
    
    def self.offers_by_agent(user)
      @@offers.select { |item| item.owner == user }
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

    # @internal_note Breaks layers somewhat, but if we don't do this here we'd need some way of communicating with the application, which would break layers too
    def delete_image_file
      delete_public_file(self.image_file_name)
    end


    def add_comment new_comment
      comments << new_comment unless comments.include?(new_comment)
    end

    # @param [String] pattern The string to be found in the name or about. Case ignored, all languages checked.
    def self.find_item(pattern)
      @@items.select { |item|
        item.active && (item.name.include_i?(pattern) || item.about.include_i?(pattern))
      }
    end

    def is_offer?()
      Item.offer_by_id(self.id) == self # what about @@offers.include?(self)
    end

    # @param [Agent] selling_agent The agent selling the item (getting the money)
    def sell(selling_agent)
      fail "no offer" unless self.is_offer?()
      selling_agent.credit += self.safe.savings
      Item.transform_offer_to_item(self)
    end

    # same as {#find_item} but for offers.
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

    # @internal_note This is static (class method) because it modifies class data.
    def self.transform_offer_to_item(offer)
      offer.safe = nil
      @@items.push(offer)
      @@offers.delete(offer)
    end
    
    def self.all_auctions
      @all_auctions = @@items.select{ |item| !item.auction.nil? }
    end
  end
end
