class UserBan < ActiveRecord::Base
  set_primary_key "user_ban_id"
  set_table_name "user_bans"
  belongs_to :user , :foreign_key=>:pariah_id
end
