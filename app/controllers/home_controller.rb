################################
# Home Page
#
# Andrew, 10/2008-
################################

class HomeController < ApplicationController


  # H-TOWN Timezone
  @@time_zone='Central Time (US & Canada)'

  ################################
  # ACTIONS
  ################################

  def index
	if mobile_request?
	  redirect_to :action=>"mobile"
	end


	@page_title="News, Events Calendar, Musician Resources, Local Releases"

  end

  # the mobile index page
  def mobile

	@page_title="News, Events Calendar, Musician Resources, Local Releases | Mobile Edition"

  end

  private

  helper_method :topic_list, :shows_today, :shows_this_week, :articles, :albums

  def topic_list
	@topic_list ||= Topic.recent_posts(1, 6)
  end

  def shows_this_week
	@shows_this_week ||= Event.getShowsThisWeek()
  end

  def shows_today
	@shows_today ||= Event.getShowsToday()
  end

  def articles
	@articles ||= Content.find(:all, :order=>"display_date desc", :conditions => "status_id=2", :limit=>4)
  end

  def albums
	@albums ||= Album.find(:all, :joins=>:genre, :select=>"genres.genre_name, albums.*",
					   :order=>"release_date desc", :limit=>4)
  end

end
