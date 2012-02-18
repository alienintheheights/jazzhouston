################################
# Home Page
#
# Andrew, 10/2008-
################################

class HomeController < ApplicationController


  # H-TOWN Timezone
  @@TZ='Central Time (US & Canada)'

  ################################
  # ACTIONS
  ################################

  def index
    if mobile_request?
      redirect_to :action=>"mobile"
    end
    # get all shows for today
    @curTime = Time.now.in_time_zone(@@TZ)

    @showsToday = Event.getShowsToday(@curTime)
    @showsThisWeek = Event.getShowsThisWeek(@curTime)

    @articles=Content.find(:all, :order=>"display_date desc", :conditions => "status_id=2", :limit=>9)

    @albums=Album.find(:all, :joins=>:genre, :select=>"genres.genre_name, albums.*",
                       :order=>"release_date desc", :limit=>5)

    @page_title="News, Events Calendar, Musician Resources, Local Releases"

  end

  # the mobile index page
  def mobile

    # get all shows for today
    @curTime = Time.now.in_time_zone(@@TZ)

    @showsToday = Event.getShowsToday(@curTime)
    @showsThisWeek = Event.getShowsThisWeek(@curTime)

    @articles=Content.find(:all, :order=>"display_date desc", :conditions => "status_id=2", :limit=>5)

    @albums=Album.find(:all, :joins=>:genre, :select=>"genres.genre_name, albums.*",
                       :order=>"release_date desc", :limit=>5)

    @page_title="News, Events Calendar, Musician Resources, Local Releases"

  end

end
