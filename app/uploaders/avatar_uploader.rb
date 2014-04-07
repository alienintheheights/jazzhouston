##############
# CarrierWave uploader:
# 	PaperClip migration version
##############
class AvatarUploader < CarrierWave::Uploader::Base

  include CarrierWave::Compatibility::Paperclip


  storage :fog

  # use paperclip path
  def paperclip_path
    ':rails_root/public/uploads/:class/photos/:id/:style/:basename.:extension'
  end

  # Include RMagick
  include CarrierWave::RMagick

  # Create different versions of your uploaded files:
  version :thumb do
    process :resize_and_pad => [50, 50, "white", Magick::CenterGravity]
    process :custom_crop
    process :convert => "png"
  end

  # Create different versions of your uploaded files:
  version :small do
    process :resize_and_pad => [150, 150, "white", Magick::CenterGravity]
    process :custom_crop
    process :convert => "png"
  end

  # Create different versions of your uploaded files:
  version :large do
    process :resize_and_pad => [500, 500, "white", Magick::CenterGravity]
    process :custom_crop
    process :convert => "png"
  end


  private

  def radial_blur(amount)
    manipulate! do |img|
      img.radial_blur(amount)
      img = yield(img) if block_given?
      img
    end
  end

  def custom_crop
    manipulate! do |img|

      image = MiniMagick::Image.open(current_path)
      crop_w = (image[:width] * 0.8).to_i
      crop_h = (image[:height] * 0.8).to_i
      crop_x = (image[:width] * 0.1).to_i
      crop_y = (image[:height] * 0.1).to_i

      img.crop "#{crop_w}x#{crop_h}+#{crop_x}+#{crop_y}"
      img.strip

      img = yield(img) if block_given?
      img
    end
  end


end
