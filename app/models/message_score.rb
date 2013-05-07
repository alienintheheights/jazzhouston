class MessageScore < ActiveRecord::Base

  set_primary_key "message_score_id"
  set_table_name "message_scores"
  belongs_to :user, :foreign_key=>:user_id

  def self.vote(user_id, message_id, incr_value)
	scores = MessageScore.where("user_id=? and message_id=?", user_id, message_id)
	if (scores && scores.length!=0)
	  puts "Found a match for message_id=" + message_id.to_s + "user_id = " + user_id.to_s
	  puts "returning"
	  return nil  # can't vote twice
	end

	new_score = MessageScore.new()
	new_score.user_id = user_id
	new_score.message_id = message_id
	new_score.save!

	message = Post.find(message_id)
	message.rating = message.rating + incr_value
	message.save!
	return message   # return value

  end


end
