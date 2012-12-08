module Market
  class Comment
    attr_reader :creator, :text
    @@comments = []
    def initialize(params={})
       assert_kind_of(Agent, params[:creator])
       assert_kind_of(String, params[:text]) if params[:text]
       @creator = params[:creator]
       @text = params[:text] || ""
      @@comments << self
    end

    # params: hash, recognized: :creator (required), :text (empty by default)
    def self.init(params={})
      self.new(params)
    end

    def to_s
      @text
    end

    def creator
      @creator
    end

    def self.all
      return @@comments
    end
  end

end
