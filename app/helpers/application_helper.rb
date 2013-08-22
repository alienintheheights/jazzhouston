# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  ########################################
  ##  detect mobile based on USER_AGENT,
  ##   request header, or subdomain
  #########################################
  def mobile_request?
	request.user_agent =~ /Mobile|webOS/
  end

end
