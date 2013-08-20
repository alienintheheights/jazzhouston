class Content < ActiveRecord::Base
  set_table_name "content"
  set_primary_key "content_id"
  attr_accessible :photo
  has_attached_file :photo,
					:styles => {:thumb => '120x120>', :large => '640x480>', :small  => "400x400>" },
					:default_style => :thumb,
					:url => "/uploads/:class/:attachment/:id/:style/:filename",
					:path => ":rails_root/public/uploads/:class/:attachment/:id/:style/:filename"

  define_index do
	indexes title, :sortable => true
	indexes body_text
	indexes display_date
	indexes teaser
  end



end
