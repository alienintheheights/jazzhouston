require 'open-uri'
require 'cgi'

module TinyUrlHelper
  def tinyurl(url)
    begin
      open("http://tinyurl.com/api-create.php?url=#{CGI.escape(url)}").read
    rescue
      # On an error, we just skip the tinyurl and use an ordinary one.
      url
    end
  end
end