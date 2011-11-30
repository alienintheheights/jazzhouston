class MessageScore < ActiveRecord::Base
  set_primary_key "message_score_id"
  set_table_name "message_scores"
  belongs_to :user, :foreign_key=>:user_id
end
