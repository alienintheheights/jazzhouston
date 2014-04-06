################################
# Venues class
# references table Venues
#
# Andrew, 10/2008
################################

class VenuesController < ApplicationController

  #require 'json/objects'

  # Be sure to include AuthenticationSystem in Application Controller instead
  include ExtjsRails
  include JazzhoustonAuth

  before_filter :is_editor?, :only =>[:edit, :new, :update, :create, :destroy]

  ################################
  # ACTIONS
  ################################

  # the index page
  def index
    @page_title="Houston Music Venues"
    respond_to do |format|
      flash[:notice]="Event Deleted"
      format.mobile { redirect_to :venue=>@venue, :action=>"index_mobile"   }
      format.html { redirect_to :venue=>@venue, :action=>"index"   }
    end
  end

  # venue page
  def about
    @key = (mobile_request?)? "ABQIAAAAzdwfpQzkLHpT1vm4p-HpZxRu0WNbvnfuRTApAt3p9akP7mvt_BSueC6b0kgIIhtGFn0Ree50gx-z7g" : "ABQIAAAAzdwfpQzkLHpT1vm4p-HpZxQhxxKw40N0I53x6-l4Z3M-dBKQbxTvKrXL8khco-2AjQvIHGVcigFIsQ"
    @venue=Venue.find(params[:id])
    t=Time.now
    curDate=t.strftime("%Y-%m-%d")
    @onenighters=Event.find(:all,
                            :conditions=>["venue_id=? and event_type_id=1 and show_date>=?",@venue.venue_id, curDate],
                            :order=>"show_date")
    @steadies=Event.find(:all,
                         :conditions=>["venue_id=? and event_type_id=2",@venue.venue_id], :order=>"day_of_week")
    @dow =["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]

    @page_title="Jazz/Houston: #{@venue.title}"
    respond_to do |format|
      format.html {render :template => "venues/about.erb"}
      format.mobile {render :template => "venues/about_mobile.erb"}
    end
  end

  #########################################
  # EXT-JS JSON Happy AJAX Search
  #########################################
  def search_ext
    @search_term=params[:query].downcase
    @venues = Venue.find(:all,:select=>"venue_id, title",
                         :order=>"title",
                         :conditions=>"status_id=2 and lower(title) like '%"+@search_term+"%'")

    render :json => to_ext_json(@venues)

  end

  ################################
  # Write Methods

  ################################

  # GET /comments/new
  # GET /comments/new.xml
  def new
    @venue = Venue.new

    respond_to do |format|
      format.mobile # new.html.erb
      format.html # new.html.erb
      format.xml  { render :xml => @venue }
    end
  end

  # GET /news/1/edit
  def edit
    @venue = Venue.find(params[:id])
  end

  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    @venue = Venue.find(params[:id])
    @venue.update_attributes(params[:venue])
    respond_to do |format|
      format.mobile { render :venue=>@venue, :action=>"edit", :id=>@venue.venue_id   }
      format.html { render :venue=>@venue, :action=>"edit", :id=>@venue.venue_id   }
      format.xml  { head :ok }
    end
  end


  # POST /news
  # POST /news.xml
  def create
    @venue = Venue.new(params[:venue])

    respond_to do |format|
      if @venue.save
        flash[:notice] = 'Venue was successfully created.'
        format.mobile { redirect_to :venue=>@venue, :action=>"edit", :id=>@venue.venue_id  }
        format.html { redirect_to :venue=>@venue, :action=>"edit", :id=>@venue.venue_id  }
        format.xml  { render :xml => @venue, :status => :created, :location => @venue }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @venue.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /news/1
  # DELETE /news/1.xml
  def destroy
    @venue = Venue.find(params[:id])
    @venue.destroy

    respond_to do |format|
      format.mobile { redirect_to(@venue) }
      format.html { redirect_to(@venue) }
      format.xml  { head :ok }
    end
  end



end
