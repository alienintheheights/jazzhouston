# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '3ae23f8d058344bd25b831bdf54f57bb'

  # See ActionController::Base for details
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password").
  # filter_parameter_logging :password

  ActionController::Base.cache_store = :file_store, "/home/jazzhouston/tmp/cache"

  include AuthenticatedSystem


  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie

  # mobile considerations
  layout :detect_browser
  #before_filter :redir_to_ssl
  before_filter :adjust_format_for_mobile

  # keep things save
  def redir_to_ssl
	if !request.ssl?
	  redirect_to 'https://'+request.host_with_port+request.path
	end
  end
  ### FLOW
  # before_filter :adjust_format_for_mobile
  #     checks if mobile_request?
  #        checks subdomain or format parameter
  #        else scans USER_AGENT and tests against MOBILE_BROWSERS
  #
  # request.format gets the value set by rails from params[:format]

  ########################################
  ##  detect mobile based on USER_AGENT,
  ##   request header, or subdomain
  #########################################
  def mobile_request?
	if (cookies[:prefer_full_site])
	  return false
	elsif (cookies[:prefer_mobile])
	 return true
	end

	if (request.user_agent =~ /Mobile|webOS/ && !(request.user_agent =~ /iPad/) )
	  cookies[:prefer_mobile] = "true"
	  return true
	end
	false
  end

  private

  ########################################
  ##  add a :mobile ("text/html") request
  ##   header if mobile
  #########################################
  def adjust_format_for_mobile
	request.format = :mobile if mobile_request?

  end

  ########################################
  ##  no layout if AJAX (xhr), otherwise
  ##    respond based on mobile_request?
  #########################################
  def detect_browser
	# return false if (request.xhr?)
	(mobile_request?)?  "jqm_application" : "application"
  end


  def selected_layout
	session.inspect # force session load
	if session[:layout]
	  return (session["layout"] == "mobile") ? "jqm_application" : "application"
	end
	nil
  end


end
