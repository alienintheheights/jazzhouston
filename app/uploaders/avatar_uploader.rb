##############
# CarrierWave uploader:
# 	PaperClip migration version
##############
class AvatarUploader < CarrierWave::Uploader::Base

  include CarrierWave::Compatibility::Paperclip

  # use paperclip path
  def paperclip_path
	':rails_root/public/uploads/:class/photos/:id/:style/:basename.:extension'
  end

  # Include RMagick
  include CarrierWave::RMagick

  # Create different versions of your uploaded files:
  version :thumb do
	process :resize_and_pad => [50, 50, "white", Magick::CenterGravity]
	process :convert => "png"
  end

  # Create different versions of your uploaded files:
  version :small do
	process :resize_and_pad => [150, 150, "white", Magick::CenterGravity]
	process :convert => "png"
  end

  # Create different versions of your uploaded files:
  version :large do
  process :resize_and_pad => [500, 500, "white", Magick::CenterGravity]
  process :convert => "png"
  end


end
