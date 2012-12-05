module SecurityHelpers
    def xss(text)
      escaped = Rack::Utils.escape_html(text)
      escaped.gsub("&gt;", ">")
    end
end

module NumericHelpers
  def ts(s)
    s.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1'")
  end
end

module MarkupHelpers
  def mdown_to_html(mdown)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    markdown.render(mdown)
  end
end

def admin!
  unless authorized?
    response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
    throw(:halt, [401, "Not authorized\n"])
  end
end

def authorized?
  @auth ||=  Rack::Auth::Basic::Request.new(request.env)
  @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['admin', 'password']
end


helpers SecurityHelpers, NumericHelpers, MarkupHelpers

