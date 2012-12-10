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
    response['WWW-Authenticate'] = %(Basic realm="#{ADMIN_AREA_LOGIN_MESSAGE}")
    throw(:halt, [401, "Not authorized\n"])
  end
end

def authorized?
  @auth ||=  Rack::Auth::Basic::Request.new(request.env)
  @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [ADMIN_USERNAME, ADMIN_PASSWORD]
end

helpers SecurityHelpers, NumericHelpers, MarkupHelpers

