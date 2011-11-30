class Event < ActiveRecord::Base
    set_primary_key "event_id"
    belongs_to :venue

    @@TZ='Central Time (US & Canada)'

    # Exclude password info from json output.
    def as_json(options={})
        options[:except] ||= :password
        super(options)
    end

    # method to get shows
    def self.getOneNightShowsToday(curTime)

        showDate = curTime.strftime("%Y-%m-%d")
        dow = curTime.strftime("%w")

        # one-nighters (event_type_id=1)
        @onenighters = Event.find(:all, :include => [:venue], :conditions=>["event_type_id=1 and show_date=?",showDate], :order=>"performer, show_time")

    end

    # method to get shows
    def self.getSteadiesToday(curTime)

        showDate = curTime.strftime("%Y-%m-%d")
        dow = curTime.strftime("%w")

        # steady gigs (event_type_id=2)
        @steadies = Event.find(:all, :include => [:venue], :conditions=>["event_type_id=2 and day_of_week=?",dow], :order=>"performer, show_time")

    end

    # method to get shows
    def self.getShowsToday(curTime)

        showDate = curTime.strftime("%Y-%m-%d")
        dow = curTime.strftime("%w")

        # one-nighters (event_type_id=1)
        @onenighters = Event.find(:all, :include => [:venue], :conditions=>["event_type_id=1 and show_date=?",showDate], :order=>"performer, show_time")

        # steady gigs (event_type_id=2)
        @steadies = Event.find(:all, :include => [:venue], :conditions=>["event_type_id=2 and day_of_week=?",dow], :order=>"performer, show_time")

	return @onenighters + @steadies
    end

    def self.getShowsThisWeek(curTime)

        t = Time.now
        @todayDate = t.in_time_zone(@@TZ).strftime("%Y/%m/%d")
        tomorrowTime = t + 1.days
        tomorrowDate = tomorrowTime.in_time_zone(@@TZ).strftime("%Y-%m-%d")

        # get shows thru Sun (i.e., saturday+1)
        dow = 6 - t.wday
        t += (24*60*60)*(dow+1)
        satDate = t.in_time_zone(@@TZ).strftime("%Y-%m-%d")

        @weekendShows = Event.find(:all, :conditions=>["event_type_id=1 and show_date between ? and ?",tomorrowDate, satDate], :order=>"show_date")

    end

end

   
