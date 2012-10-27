module Market
  class Organization < Agent
    # Very similar to user
    attr_accessor :members, :admin  # for now... see https://github.com/ese-unibe-ch/ese2012-team3/wiki/Mapping-Organization---User
    # TODO Store roles of members. Make sure there's always an admin.

    @@organizations = []
    @@organization_id_counter = 1

    # constructor - initializes the user and gives a credit of 100 if nothing else is specified
    # @param [Object] params - dictionary of symbols, recognized: :name, :credit, :about
    # required: :name
    def self.init(params={})
      fail "Organization name missing" unless params[:name] && params[:name].length > 0
      fail "Organization with given name already exists" if self.organization_by_name(params[:name])
      fail "Organization needs an admin" unless params[:admin].is_a?(Market::User)
      org = self.new
      org.members = []
      org.admin = params[:admin]
      org.add_member(params[:admin])
      org.name = params[:name]
      org.credit = params[:credit] || 100
      org.about = params[:about] || ""
      org.wishlist = []
      @@organizations << org
      org.id = @@organization_id_counter
      @@organization_id_counter = @@organization_id_counter + 1
      org
    end

    # returns the global organization list
    def self.all
      @@organizations
    end

    def self.delete_all
      @@organizations = []
      @@organization_id_counter = 0
    end

    def self.organization_by_id(id)
      org = @@organizations.detect { |org| org.id == id }
      if org == nil
        fail "No organization with id #{id}"
      end
      org
    end

    def self.has_organization_with_id?(id)
      return @@organizations.detect { |user| user.id == id.to_i } != nil
    end

    # TODO Reduce usage - use id instead
    def self.organization_by_name(name)
      @@organizations.detect { |user| user.name == name }
    end

    # Lists organizations the user works for
    def self.organizations_by_user(user)
      @@organizations.select { |org| org.members.include?(user) }
    end

    def has_member(user)
      self.members.include?(user)
    end

    def add_member(user)
      raise "cannot add same user twice!" if self.has_member(user)
      members << user
    end

    def remove_member(user)
      raise 'cannot remove admin, set a new admin first!' if user == self.admin
      raise "cannot remove member #{user.name}, he isn't a member!" unless self.members.include?(user)

      members.delete(user)
    end

    # TODO move to a more appropriate place
    def profile_route
      "/organization/#{self.id}"
    end

    def delete_image_file
      delete_public_file(self.image_file_name) unless self.image_file_name == nil
    end

    # Missing: Deletion...

  end
end
