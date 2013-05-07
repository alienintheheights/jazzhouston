# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  MOBILE_BROWSERS = ["android", "ipod", "opera mini", "blackberry", "palm","hiptop","avantgo","plucker", "xiino","blazer","elaine", "windows ce; ppc;", "windows ce; smartphone;","windows ce; iemobile", "up.browser","up.link","mmp","symbian","smartphone", "midp","wap","vodafone","o2","pocket","kindle", "mobile","pda","psp","treo"]

  def mobile_user_agent?
    if (request.xhr?)
      return false
    end

    agent = request.headers["HTTP_USER_AGENT"].downcase
    matched_agent = "application"
    MOBILE_BROWSERS.each do |m|
      matched_agent = "mobile_application" if agent.match(m)
    end
    return  matched_agent
  end
end
