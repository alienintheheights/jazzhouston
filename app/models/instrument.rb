
class Instrument < ActiveRecord::Base
    set_table_name "instruments"
    set_primary_key "instrument_id"
    has_many :musician_instruments, :dependent => :destroy
    has_many :users, :through => :musician_instruments
end