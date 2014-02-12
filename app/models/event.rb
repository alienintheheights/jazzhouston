class Event < ActiveRecord::Base
  set_primary_key "event_id"
  belongs_to :venue
  has_one :user, :foreign_key => "user_id"

  @@time_zone='Central Time (US & Canada)'

  attr_accessible :venue, :event_type_id, :performer, :about, :day_of_week,
                  :artist_id, :related_url, :venue_id, :show_date, :show_time, :jam_flag

  # Exclude password info from json output.
  def as_json(options={})
    options[:except] ||= :password
    super(options)
  end

  # method to get ALL shows & steadies this week
  def self.shows_on_date(current_time=Time.now.in_time_zone(@@time_zone))

    show_date = current_time.strftime("%Y-%m-%d")
    dow = current_time.strftime("%w")

    # one-night shows (event_type_id=1)
    shows = Event.find(:all, :include => [:venue], :conditions=>["event_type_id=1 and show_date=?",show_date], :order=>"venues.listeningroom desc, performer, show_time")
    # steady gigs (event_type_id=2)
    steadies = Event.find(:all, :include => [:venue], :conditions=>["event_type_id=2 and day_of_week=?",dow], :order=>"performer, show_time")

    return shows + steadies
  end

  # method to get remaining shows this week
  # the IDE is complaining about the length of this function name: whatever!
  def self.remaining_shows_this_week()
    t = Time.now
    tomorrow_time = t + 1.days
    tomorrow_date = tomorrow_time.in_time_zone(@@time_zone).strftime("%Y-%m-%d")
    # get shows thru Sun (i.e., saturday+1)
    dow = 6 - t.wday
    t += (24*60*60)*(dow+1)
    saturday_date = t.in_time_zone(@@time_zone).strftime("%Y-%m-%d")

    Event.find(:all, :include => [:venue], :conditions=>["event_type_id=1 and show_date between ? and ?",tomorrow_date, saturday_date], :order=>"show_date, venues.listeningroom desc")

  end

end

   
