module Market
  class Organization < Agent
    # Very similar to user
    attr_accessor :members  # for now... see https://github.com/ese-unibe-ch/ese2012-team3/wiki/Mapping-Organization---User

    @@organizations = []
    @@organization_id_counter = 0

    # constructor - initializes the user and gives a credit of 100 if nothing else is specified
    # @param [Object] params - dictionary of symbols, recognized: :name, :credit, :about
    # required: :name
    def self.init(params={})
      fail "Organization name missing" unless params[:name] && params[:name].length > 0
      fail "Organization with given name already exists" if self.organization_by_name(params[:name])
      org = self.new
      org.members = []
      org.name = params[:name]
      org.credit = params[:credit] || 100
      org.about = params[:about] || ""
      @@organizations << org
      org.id = @@organization_id_counter
      @@organization_id_counter = @@organization_id_counter + 1
      org
    end

    # returns the global user list
    def self.all
      @@organizations
    end

    def self.delete_all
      @@organizations = []
    end

    # TODO Reduce usage - use id instead
    def self.organization_by_name(name)
      @@organizations.detect { |user| user.name == name }
    end

    # Lists organizations the user works for
    def self.organizations_by_user (user)
      @@organizations.select { |org| org.members.include?(user) }
    end

  end
end