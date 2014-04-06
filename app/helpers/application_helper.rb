# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  ########################################
  ##  detect mobile based on USER_AGENT,
  ##   request header, or subdomain
  #########################################
  def mobile_request?
	  request.user_agent =~ /Mobile|webOS/
  end

  def resource_name
     :user
   end

   def resource
     @resource ||= User.new
   end

   def devise_mapping
     @devise_mapping ||= Devise.mappings[:user]
   end

end
