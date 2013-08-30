class Content < ActiveRecord::Base
  set_table_name "content"
  set_primary_key "content_id"
  attr_accessible :title, :content_type_id, :content_sub_type, :author, :body_text,
				  :local_flag, :external_image_url, :photo_file_name, :author_id,
				  :status_id, :teaser, :related_url, :html_break_flag,
				  :display_date, :image

  ## CarrierWave gem
  mount_uploader :image, AvatarUploader, :mount_on => :photo_file_name


end
