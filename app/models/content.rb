class Content < ActiveRecord::Base
  set_table_name "content"
  set_primary_key "content_id"
 attr_accessible :image, :external_image_url

  ## Thinking-Sphinx Search gem
  #define_index do
  #	indexes title, :sortable => true
  #	indexes body_text
  #	indexes display_date
  #	indexes teaser
  # end

  ## CarrierWave gem
  mount_uploader :image, AvatarUploader, :mount_on => :photo_file_name


end
