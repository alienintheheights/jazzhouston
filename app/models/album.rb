class Album < ActiveRecord::Base
  set_primary_key "album_id"
  belongs_to :genre  
end
