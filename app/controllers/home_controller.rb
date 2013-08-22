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
	  @page_title="Jazz/Houston"
	else
	  @page_title="News, Events Calendar, Musician Resources, Local Releases"
	end

	respond_to do |format|
	  format.html  {render :template => "/home/index.erb"}
	  format.mobile {render :template => "/home/mobile.erb"}
	end
  end

  # the mobile index page
  def mobile

	@page_title="Jazz/Houston"

  end

  private

  helper_method :topic_list, :shows_on_date, :remaining_shows_this_week, :articles, :albums

  def topic_list
	@topic_list ||= Topic.recent_posts(1, 6)
  end

  def remaining_shows_this_week
	@remaining_shows_this_week ||= Event.remaining_shows_this_week()
  end

  def shows_on_date
	@shows_today ||= Event.shows_on_date()
  end

  def articles
	@articles ||= Content.find(:all, :order=>"display_date desc", :conditions => "status_id=2", :limit=>4)
  end

  def albums
	@albums ||= Album.find(:all, :joins=>:genre, :select=>"genres.genre_name, albums.*",
					   :order=>"release_date desc", :limit=>4)
  end

end
