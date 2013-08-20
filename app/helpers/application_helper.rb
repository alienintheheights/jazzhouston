# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
##  evolving array of mobile UA strings
  HELPER_MOBILE_BROWSERS = ["android", "iphone", "iemobile", "blackberry"]

  ########################################
  ##  detect mobile based on USER_AGENT,
  ##   request header, or subdomain
  #########################################
  def mobile_request?
	if (params[:format] == "mobile")
	 return true
	end

	agent = request.headers["HTTP_USER_AGENT"].downcase
	HELPER_MOBILE_BROWSERS.each do |m|
	  if agent.match(m)
		return true
	  end
	end
	false
  end

end
