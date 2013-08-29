class Venue < ActiveRecord::Base
  set_primary_key "venue_id"
  attr_accessible :photo, :external_image_url

  ## CarrierWave gem
  mount_uploader :photo, AvatarUploader


end

   