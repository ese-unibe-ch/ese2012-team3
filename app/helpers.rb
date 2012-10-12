require 'sinatra/base'

module Sinatra
  module Security
      def xss(text)
        Rack::Utils.escape_html(text)
      end
  end

  helpers Security
end
