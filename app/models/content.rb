class Content < ActiveRecord::Base
  set_table_name "content"
  set_primary_key "content_id"
  has_attached_file :photo,
                    :styles => {:thumb => '120x120>', :large => '640x480>', :small  => "400x400>" },
                    :default_style => :thumb,
                    :url => "/uploads/:class/:attachment/:id/:style/:filename",
                    :path => ":rails_root/public/uploads/:class/:attachment/:id/:style/:filename"
end
