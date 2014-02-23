require 'open-uri'
require 'app/helpers/twitter_module.rb'
require 'app/helpers/tiny_url_helper.rb'
require 'app/models/event.rb'
task :tweet_shows => :environment do
  include TwitterModule
  include TinyUrlHelper
  include ActionView::Helpers::TextHelper

  puts "Running the day's shows to Twitter"

  @messages = []
  shows_on_date = Event.shows_on_date
  unless shows_on_date.nil?
    shows_on_date.each do |item|
      url = 'http://jazzhouston.com/events/details/' + item.event_id.to_s
      link = tinyurl(url)
      # catch Error
      if link == "Error"
        link = url
      end
      str = item.performer.to_s + ': ' + item.show_time + ' at ' + item.venue.title.to_s + ' ' + link  + ' #jazzhouston'
      str = truncate(str, :length => 140)
      @messages.push(str)
    end
    # now post to twitter in reverse order
    @messages.reverse!
    @messages.each { |item|
      # post to Twitter
      puts "posting to twitter: #{item}"
      tweet_message(item)
    }

  end
end