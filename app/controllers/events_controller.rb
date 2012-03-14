################################
# Events class
# references table Events
# 1:to:1 relations to Venues
#
# Andrew, 10/2008
################################

class EventsController < ApplicationController

  include AuthenticatedSystem

  before_filter :login_required, :only =>[:update, :create, :new, :edit, :destroy, :update_featured]

  respond_to :html, :js, :xml, :json

  ################################
  # ACTIONS
  ################################

  # H-TOWN Timezone
  @@TZ='Central Time (US & Canada)'

  # the date-based page
  def day

    #pattern = /^(\d{4})\/(\d{1,2})\/(\d{1,2})$/
    #dateParam = params[:rest]
    #if (dateParam =~ pattern)
    # setup the date math based on the custom route URL: /events/year/month/day
    #    @curTime = Time.local(params[:date])
    #else

    # setup the date math based on the custom route URL: /events/year/month/day
    if params[:year] != "" && params[:month] != "" && params[:day] != ""
      @curTime = Time.local(params[:year],params[:month],params[:day])
    else
      @curTime = Time.now.in_time_zone(@@TZ)
    end

    @onenighters = Event.getOneNightShowsToday(@curTime)
    @steadies = Event.getSteadiesToday(@curTime)

    # for use in the View
    @page_title =  @curTime.strftime("%A, %B %d %Y")
  end

  # index page
  def index

    @curTime = Time.now.in_time_zone(@@TZ)

    @showsToday = Event.getShowsToday(@curTime)
    @showsThisWeek = Event.getShowsThisWeek(@curTime)

    # Jam Sessions
    @jams = Event.find(:all, :include => [:venue], :conditions=>"jam_flag=1", :order=>"day_of_week, show_time")

    # for use in the View
    @curTime = Time.now.in_time_zone(@@TZ)
    @page_title = "Local Music Calendar"
  end


  # all shows page
  def shows
    curDate = Time.now.in_time_zone(@@TZ).strftime("%Y-%m-%d")
    @shows = Event.find(:all, :conditions=>["event_type_id=1 and show_date >= ?",curDate], :order=>"show_date")

    # for use in the View
    @page_title = "All Upcoming Shows"
  end

  # details pages
  def details
    # Google API Key
    @key = (mobile_request?)? "ABQIAAAAzdwfpQzkLHpT1vm4p-HpZxRu0WNbvnfuRTApAt3p9akP7mvt_BSueC6b0kgIIhtGFn0Ree50gx-z7g" : "ABQIAAAAzdwfpQzkLHpT1vm4p-HpZxQhxxKw40N0I53x6-l4Z3M-dBKQbxTvKrXL8khco-2AjQvIHGVcigFIsQ"

    @show = Event.find(params[:id])

    if (@show && @show.artist_id && @show.artist_id>0 && User.exists?(@show.artist_id))
      @player= User.find(@show.artist_id)
    end

    if (@show && @show.venue_id)
      @venue=Venue.find(@show.venue_id)
    end

    # for use in the View
    @dow =["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    @page_title = @show.performer
  end

  # featured event
  def featured
    @fshow=Event.find(:first, :conditions => { :featured_flag => 1 })
    render :layout=>false
  end

  # sets featured show
  def update_featured

    if request.post?

      if (params[:feature_id])

        cur_featured=Event.find(:first,:conditions=>"featured_flag=1")
        cur_featured.featured_flag=0
        cur_featured.save!

        @fshow=Event.find(params[:feature_id])
        @fshow.featured_flag=1
        @fshow.save!

        flash[:notice]="feature updated"

      end


    else
      @fshow=Event.find(:first, :conditions => { :featured_flag => 1 })
    end

    @page_title = "Set Show Feature"
  end

  # rss feed
  def rss
    response.headers["Content-Type"] = "application/rss+xml; charset=utf-8"

    @curTime = Time.now.in_time_zone(@@TZ)

    @showlist = Event.getShowsToday(@curTime)
    render :layout=>false
  end


  # rss feed
  def rss_block
    redirect_to :action=>"rssblock"
  end


  # rss feed
  def rssblock
    response.headers["Content-Type"] = "application/rss+xml; charset=utf-8"

    @curTime = Time.now.in_time_zone(@@TZ)
    # hack to fetch shows in blocks of 3 at a time
    t2 = Time.parse(@curTime.strftime("%a, %d %b %Y 09:30:00 CST")).in_time_zone(@@TZ)
    @segment = (2*(@curTime-t2)/3660).to_int

    @showlist = Event.getShowsToday(@curTime)
    render :layout=>false
  end

  # ajax rotate call
  def rotate
    @curTime = Time.now.in_time_zone(@@TZ)
    Event.getShowsToday(@curTime)


  end

  # calendar page
  def calendar
    @curTime = Time.now.in_time_zone(@@TZ)
    @page_title = "Calendar"
  end


  ################################
  # Write Methods

  ################################


  # EDIT READ
  def edit
    @event = Event.find(params[:id])
    if (@event.event_type_id==2)
      @event.show_date=nil
    end
    if (@event.artist_id && @event.artist_id>0 && User.exists?(@event.artist_id))
      @player = User.find(@event.artist_id)
    end

  end

  # EDIT WRITE
  def update
    @event = Event.find(params[:id])
    if (@event.artist_id && @event.artist_id>0 && User.exists?(@event.artist_id))
      @player = User.find(@event.artist_id)
    end
    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.mobile { redirect_to :event=>@event, :action=>"edit", :id=>@event.event_id   }
        format.html { redirect_to :event=>@event, :action=>"edit", :id=>@event.event_id   }
        format.xml  { head :ok }
      else
        format.mobile { render :action => "edit" }
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end


  def new
    @event = Event.new
  end

  # NEW WRITE
  def create
    @event = Event.new(params[:event])
    if (@event.artist_id && @event.artist_id>0)
      @player = User.find(@event.artist_id)
    end
    flash[:notice] = 'Your event has been created!'
    respond_to do |format|
      if @event.save
        flash[:notice] = 'Event was successfully created.'
        format.mobile {redirect_to :event=>@event, :action=>"edit", :id=>@event.event_id  }
        format.html {redirect_to :event=>@event, :action=>"edit", :id=>@event.event_id  }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.mobile { render :action => "new" }
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      flash[:notice]="Event Deleted"
      format.mobile { redirect_to :event=>@event, :action=>"index"   }
      format.html { redirect_to :event=>@event, :action=>"index"   }
      format.xml  { head :ok }
    end
  end


end
