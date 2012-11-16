module Market
  class Comment
    attr_reader :creator, :text

    def initialize(params={})
       assert_kind_of(Agent, params[:creator])
       assert_kind_of(String, params[:text]) if params[:text]
       @creator = params[:creator]
       @text = params[:text] || ""
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
  end

end
