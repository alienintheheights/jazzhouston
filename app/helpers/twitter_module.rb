require 'twitter'
#
# Basic Twitter Module per rails gem
#
module TwitterModule


  ## Auth against JH Twitter Account
  ## This module may be called from a controller or a rake task, the
  ## difference for which is in how the init is called.
  ## safe-guarding by creating a singleton pattern for the client.
  def configinit
    @twitterclient = Twitter::Client.new do |config|
      config.consumer_key = TWITTER[:consumer_key]
      config.consumer_secret = TWITTER[:consumer_secret]
      config.access_token = TWITTER[:access_token]
      config.access_token_secret = TWITTER[:access_token_secret]
    end
  end

  def initialize(*)
    unless @twitterclient
      configinit
    end
    # "super" important to call super, otherwise controllers will break (no layouts, for example)
    super
  end

  # fetch from a user's timeline
  def user_timeline(username, limit)
    unless @twitterclient
      configinit
    end
    options = {
        :count => limit,
        :include_rts => true
    }
    @twitterclient.user_timeline(username, options)
  end

  # search twitter
  # TODO add a since date; limit does not apply here
  def search(query, limit)
    unless @twitterclient
      configinit
    end
    options = {
        :count => limit,
        :include_rts => true
    }
    @twitterclient.search(query, options)
  end

  # Tweet!
  def tweet_message(message)
    unless @twitterclient
      configinit
    end
    @twitterclient.update(message)
  end

end
