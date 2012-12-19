module Market

  # Comments can be made on items. They can be markdown formatted. They are not localised.
  # They store their creator and text only.
  class Comment
    attr_reader :creator # The {Agent} that commented
    attr_reader :text # supports markdown

    @@comments = [] # Array of all comments in the system. For statistics.

    # @param params a hash. Recognized keys
    #  * <tt>:creator</tt> => The {Agent} that made the comment, required
    #  * <tt>:text</tt> => <tt>String</tt> supports markdown. May be nil (replaced with "" if so)
    def initialize(params={})
       assert_kind_of(Agent, params[:creator])
       assert_kind_of(String, params[:text]) if params[:text]
       @creator = params[:creator]
       @text = params[:text] || ""
       @@comments << self
    end

    # Returns stored text.
    # @return {#text}
    def to_s
      @text
    end

    # List for statistics.
    def self.all
      return @@comments
    end
  end

end
