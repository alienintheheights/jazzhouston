class Member < ActiveRecord::Base
    set_primary_key "user_id"
    set_table_name "users"
    has_many :musician_instruments, :dependent => :destroy
    has_many :instruments, :through => :musician_instruments
end

class MusicianInstrument < ActiveRecord::Base
    set_table_name "musician_instrument"
    belongs_to :member
    belongs_to :instrument
end

class Instrument < ActiveRecord::Base
    set_table_name "instruments"
    set_primary_key "instrument_id"
    has_many :musician_instruments, :dependent => :destroy
    has_many :members, :through => :musician_instruments
end