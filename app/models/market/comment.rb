module Market
  class Comment
    attr_accessor :creator, :text

    # params: hash, recognized: :creator (required), :text (empty by default)
    def self.init(params={})
      cmt = self.new
      fail "No Comment creator supplied" unless params[:creator]
      cmt.creator = params[:creator]
      cmt.text = params[:text] || ""
      cmt
    end
  end

end
