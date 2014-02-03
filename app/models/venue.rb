class Venue < ActiveRecord::Base
  set_primary_key "venue_id"

  ## CarrierWave gem
  mount_uploader :photo, AvatarUploader


end

   