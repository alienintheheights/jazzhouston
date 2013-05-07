class Event < ActiveRecord::Base
    set_primary_key "event_id"
    belongs_to :venue

    @@time_zone='Central Time (US & Canada)'

    # Exclude password info from json output.
    def as_json(options={})
        options[:except] ||= :password
        super(options)
    end

    # method to get shows
    def self.getOneNightShowsToday(curTime)

        show_date = curTime.strftime("%Y-%m-%d")
        dow = curTime.strftime("%w")

        # one-nighters (event_type_id=1)
        @onenighters = Event.find(:all, :include => [:venue], :conditions=>["event_type_id=1 and show_date=?",show_date], :order=>"performer, show_time")

    end

    # method to get shows
    def self.getSteadiesToday(curTime)

        show_date = curTime.strftime("%Y-%m-%d")
        dow = curTime.strftime("%w")

        # steady gigs (event_type_id=2)
        @steadies = Event.find(:all, :include => [:venue], :conditions=>["event_type_id=2 and day_of_week=?",dow], :order=>"performer, show_time")

    end

    # method to get shows
    def self.getShowsToday(curTime)

        show_date = curTime.strftime("%Y-%m-%d")
        dow = curTime.strftime("%w")

        # one-nighters (event_type_id=1)
        @onenighters = Event.find(:all, :include => [:venue], :conditions=>["event_type_id=1 and show_date=?",show_date], :order=>"performer, show_time")

        # steady gigs (event_type_id=2)
        @steadies = Event.find(:all, :include => [:venue], :conditions=>["event_type_id=2 and day_of_week=?",dow], :order=>"performer, show_time")

	return @onenighters + @steadies
    end

    def self.getShowsThisWeek(curTime)

        t = Time.now
        @todayDate = t.in_time_zone(@@time_zone).strftime("%Y/%m/%d")
        tomorrow_time = t + 1.days
        tomorrow_date = tomorrow_time.in_time_zone(@@time_zone).strftime("%Y-%m-%d")

        # get shows thru Sun (i.e., saturday+1)
        dow = 6 - t.wday
        t += (24*60*60)*(dow+1)
        saturday_date = t.in_time_zone(@@time_zone).strftime("%Y-%m-%d")

        @weekendShows = Event.find(:all, :conditions=>["event_type_id=1 and show_date between ? and ?",tomorrow_date, saturday_date], :order=>"show_date")

    end

end

   
