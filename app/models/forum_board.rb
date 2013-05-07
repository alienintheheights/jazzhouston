class ForumBoard < ActiveRecord::Base
  set_primary_key "board_id"
  set_table_name "boards"
  has_many :topics

  attr_accessor  :topic_list, :admin_mode,  :page_number, :per_page, :ban_list

  @@board_list = nil

  # adds instance variables
  def enhance(opts={})
	opts.each { |k,v| instance_variable_set("@#{k}", v) }
  end

  def to_s
	"Board:id=#{self.board_id}-title=#{self.title}"
  end


  def self.board_list
	if !@@board_list
	  puts "no board list, fetching new one"
	end
	@@board_list = ForumBoard.where("status=2").select("*").order(:sort_order)
  end

end
