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
  @@time_zone='Central Time (US & Canada)'

  # index page
  def index


	@page_title = "Local Music Calendar"

	respond_to do |format|
	  format.html {render :template => "events/index.erb"}
	  format.html {render :template => "events/index_mobile.erb"}
	  format.json {render :json => all_data.to_json(:include =>:venue  )  }
	end
  end

  # the date-based page
  def day

	@cur_time = get_requested_date
	# for use in the View
	@page_title =  @cur_time.strftime("%A, %B %d %Y")

	respond_to do |format|
	  format.html {render :template => "events/day.erb"}
	  format.json {render :json =>  shows_today.to_json(:include =>:venue  )  }
	end
  end


  # all shows page
  def shows
	formatted_date = Time.now.in_time_zone(@@time_zone).strftime("%Y-%m-%d")
	@shows = Event.find(:all, :conditions=>["event_type_id=1 and show_date >= ?",formatted_date], :order=>"show_date")

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
	@page_title = @show.performer

	respond_to do |format|
	  format.html {render :template => "events/details.erb"}
	  format.json {render :json => @show.to_json(:include =>:venue  )  }
	end
  end


  # rss feed
  def rss
	response.headers["Content-Type"] = "application/rss+xml; charset=utf-8"

	render :layout=>false
  end


  # rss feed
  def rss_block
	redirect_to :action=>"rssblock"
  end


  # rss feed
  def rssblock
	response.headers["Content-Type"] = "application/rss+xml; charset=utf-8"

	# hack to fetch shows in blocks of 3 at a time
	t2 = Time.parse(@cur_time.strftime("%a, %d %b %Y 09:30:00 CST")).in_time_zone(@@time_zone)
	@segment = (2*(@cur_time-t2)/3660).to_int

	render :layout=>false
  end


  # calendar page
  def calendar
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
	@event.update_attributes(params[:event])

	respond_to do |format|
	  format.mobile { redirect_to :event=>@event, :action=>"edit", :id=>@event.event_id   }
	  format.html { redirect_to :event=>@event, :action=>"edit", :id=>@event.event_id   }
	  format.xml  { head :ok }
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
	@event.save
	flash[:notice] = 'Your event has been created!'
	respond_to do |format|
	  format.mobile {redirect_to :event=>@event, :action=>"edit", :id=>@event.event_id  }
	  format.html {redirect_to :event=>@event, :action=>"edit", :id=>@event.event_id  }
	  format.xml  { render :xml => @event, :status => :created, :location => @event }
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

  private

  helper_method  :shows_today, :remaining_shows_this_week, :jams, :all_data, :display_date, :dow

  def display_date
	@cur_time = Time.now.in_time_zone(@@time_zone)
  end

  def all_data
	if (remaining_shows_this_week.nil?)
	  return nil
	end
	all_data = remaining_shows_this_week + shows_today
  end

  def remaining_shows_this_week
	@remaining_shows_this_week = Event.remaining_shows_this_week()
  end

  def shows_today(show_date = get_requested_date)
	@shows_today = Event.get_shows_today(show_date)
  end


  def jams
	# Jam Sessions
	@jams = Event.find(:all, :include => [:venue], :conditions=>"jam_flag=1", :order=>"day_of_week, show_time")
  end

  def dow
	@dow = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
  end

  def get_requested_date
	# pattern = /^(\d{4})\/(\d{1,2})\/(\d{1,2})$/
	# setup the date math based on the custom route URL: /events/year/month/day
	if !params[:year].nil?  && !params[:month].nil? && !params[:day].nil?
	  @cur_time = Time.local(params[:year],params[:month],params[:day])
	else
	  @cur_time = Time.now.in_time_zone(@@time_zone)
	end
  end


end
