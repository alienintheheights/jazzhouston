class ForumThread < ActiveRecord::Base
  set_primary_key "thread_id"
  set_table_name "threads"
  belongs_to :board
  belongs_to :user
  has_many :messages


end
