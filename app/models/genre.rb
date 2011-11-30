class Genre < ActiveRecord::Base
  set_primary_key "genre_id"
    has_many :albums
end
