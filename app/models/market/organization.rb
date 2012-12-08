module Market

  class OrganizationMember
    @@roles = [:admin, :normal_member]
    attr_reader :agent,
                :role # any of @@roles (default)


    def initialize(agent)
      assert_kind_of(Agent, agent)
      @agent = agent
      @role = :normal_member
    end

    def role=(r)
      fail "invalid role '#{r}'" unless @@roles.include?(r)
      @role = r
    end
  end

  class Organization < Agent
    # Very similar to user
    attr_accessor :orgmembers,   # an array of objects of type OrganizationMember
                  :orgactivities # a more complete list of the activities of the organization, with each activity storing the actual user that did it

    # TODO Store roles of members. Make sure there's always an admin.

    @@organizations = []
    @@organization_id_counter = 1

    # constructor - initializes the user and gives a credit of 100 if nothing else is specified
    # @param [Object] params - dictionary of symbols, recognized: :name, :credit, :about, :admin
    # required: :name, :admin
    def self.init(params={})
      fail "Organization name missing" unless params[:name] && params[:name].length > 0
      fail "Organization with given name already exists" if self.organization_by_name(params[:name])
      fail "Organization needs an admin" unless params[:admin].is_a?(Market::User)
      org = self.new
      org.orgmembers = []
      org.activities = []
      org.orgactivities = []
      org.add_member(params[:admin]).role = :admin

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

    def members
      ms = []
      for om in self.orgmembers
        ms << om.agent
      end
      return ms
    end

    def admins
      ms = []
      for om in self.orgmembers
        ms << om.agent if om.role == :admin
      end
      return ms
    end

    # returns nil if this agent is not a member, otherwise the OrganizationMember object that manifests this membership
    def get_orgmember_by_agent(agent)
      return self.orgmembers.find(nil) {|om| om.agent == agent}
    end

    def get_member_role(agent)
       om =  self.get_orgmember_by_agent(agent)
       fail "agent is not a member" unless om
       return om.role
    end

    def is_admin?(user)
      om =  self.get_orgmember_by_agent(user)
      return false unless om
      return om.role == :admin
    end

    # role any of :normal_member : :admin
    def set_member_role(agent, role)
      om = self.get_orgmember_by_agent(agent)
      raise "agent is not a member" unless om
      raise 'cannot remove single admin, set a new admin first!' if self.admins.size == 1 && self.is_admin?(agent) && role != :admin
      om.role = role
    end

    def toggle_admin_rights(agent)
      om = self.get_orgmember_by_agent(agent)
      raise "agent is not a member" unless om
      set_member_role(om.agent, om.role == :admin ? :normal_member : :admin)
    end

    def has_member?(user)
      self.members.include?(user)
    end


    # returns the OrganizationMember object representing this membership
    def add_member(user)
      assert_kind_of(User, user)
      raise "cannot add same user twice!" if self.has_member?(user)
      om = OrganizationMember.new(user)
      self.orgmembers << om
      return om
    end

    def remove_member(user)
      set_member_role(user, :normal_member)
      raise "cannot remove member #{user.name}, he isn't a member!" unless self.members.include?(user)
      om = self.get_orgmember_by_agent(user)
      self.orgmembers.delete(om)
    end

    # TODO move to a more appropriate place
    def profile_route
      "/organization/#{self.id}"
    end

    def delete
      self.delete_as_agent
      @@organizations.delete(self)
    end

    def self.total_org_credits
      sum = 0
      for org in @@organizations
        sum += org.credit
      end
      return sum
    end

    def self.total_members
      sum = 0
      for org in @@organizations
        sum += org.members.length
      end
      return sum
    end

    def add_orgactivity(orgactivity)
      raise "cannot add non activity as activity" unless orgactivity && orgactivity.kind_of?(Activity)
      raise "cannot add same orgactivity multiple times" if self.orgactivities.include?(orgactivity)
      self.orgactivities << orgactivity
    end

  end
end
