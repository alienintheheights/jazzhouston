
class MusicianInstrument < ActiveRecord::Base
    set_table_name "musician_instrument"
    belongs_to :user
    belongs_to :instrument
end