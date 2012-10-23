module Security
    def xss(text)
      Rack::Utils.escape_html(text)
    end
end

module MarkupHelpers
  def mdown_to_html(mdown)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    markdown.render(mdown)
  end
end


helpers Security, MarkupHelpers

