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
  before_filter :adjust_format_for_mobile
  before_filter :redirect_to_mobile_if_applicable

  ##  evolving array of mobile UA strings
  MOBILE_BROWSERS = ["Android","android", "iphone", "iPhone", "ipod", "opera mini", "blackberry", "palm","hiptop","avantgo","plucker", "xiino","blazer","elaine", "windows ce; ppc;", "windows ce; smartphone;","windows ce; iemobile", "up.browser","up.link","mmp","symbian","smartphone", "midp","wap","vodafone","o2","pocket","kindle","pda","psp","treo"]

  ########################################
  ##  detect mobile based on USER_AGENT,
  ##   request header, or subdomain
  #########################################
  def mobile_request?
    if (request.subdomains.first == "m" || params[:format] == "mobile")
      return true
    end

    agent = request.headers["HTTP_USER_AGENT"].downcase
    MOBILE_BROWSERS.each do |m|
      return true if agent.match(m)
    end
    return false
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
    return false if (request.xhr?)
    (mobile_request?)?  "mobile_application" : "application"
  end

  def mobile_subdomain?
    request.subdomains.first == 'm'
  end

  def redirect_to_mobile_if_applicable
    unless mobile_subdomain? || !mobile_request? || cookies[:prefer_full_site]
      redirect_to request.protocol + "m." + request.host_with_port.gsub(/^www\./, '') +
                      request.request_uri and return
    end
  end

  def selected_layout
    session.inspect # force session load
    if session[:layout]
      return (session["layout"] == "mobile") ?
          "mobile_application" : "application"
    end
    return nil
  end

  #def rescue_404
  #   rescue_action_in_public CustomNotFoundError.new
  # end

  # def rescue_action_in_public(exception)
  #   case exception
  #     when CustomNotFoundError, ::ActionController::UnknownAction then
  #       #render_with_layout "shared/error404", 404, "standard"
  #       render :template => "site/errorpage", :exception => "404"
  #     else
  #       @message = exception
  #       render :template => "site/errorpage",  :exception => "500"
  #   end
  # end

  #    rescue_from ActionView::TemplateError do { render :template => 'site/errorpage' }



end
