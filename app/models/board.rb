class Board < ActiveRecord::Base
  set_primary_key "board_id"
  has_many :threads
end
