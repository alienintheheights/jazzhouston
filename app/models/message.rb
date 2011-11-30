class Message < ActiveRecord::Base
  set_primary_key "message_id"
  belongs_to :forum_thread
  belongs_to :user

  def prettyPostTime
      return distance_of_time_in_words(Time.now, self.pdate.to_datetime)
  end

end
