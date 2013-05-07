class Post < ActiveRecord::Base

  set_primary_key "message_id"
  set_table_name "messages"

  belongs_to :topic, :foreign_key => 'thread_id'
  belongs_to :user

  # mass updates allowed for these fields
  attr_accessible :message_text,  :status, :user_id, :ip_address, :thread_id
  # getter/setters provided for these fields
  attr_accessor :board_id, :title


  before_save :prep_post



  # facebook-style display dates
  def pretty_display_date
	distance_of_time_in_words(Time.now, self.pdate.to_datetime)
  end

  # to_s: display method
  def to_s
	"Post: thread_id=>#{thread_id}, message_text=>#{message_text}, ip_address=>#{ip_address}, user_id=>#{user_id}"
  end


  # getter for associated posts.
  def list_posts
	if (page_number)
	  offset = Post.offset(@page_number, per_page) #TODO move to helper function
	  Post.includes(:user).select("users.user_id, users.username, users.image_url, messages.*").where("thread_id=? and status=2", self.thread_id).order(:pdate).limit(@per_page).offset(offset)
	else
	  Post.includes(:user).select("users.user_id, users.username, users.image_url, messages.*").where("thread_id=? and status=2", self.thread_id).order(:pdate).limit(@per_page)
	end
  end


  #===============================
  # Class methods for Post
  #===============================

  def self.posts_by_id(thread_id, page_number, per_page)
	if (page_number)
	  page = page_number.to_i
	  offset = Post.offset(page, per_page)
	  puts per_page, offset
	  Post.includes(:user).select("users.user_id, users.username, users.image_url, messages.*").where("thread_id=? and status=2",thread_id).order(:pdate).limit(per_page).offset(offset)
	else
	  Post.includes(:user).select("users.user_id, users.username, users.image_url, messages.*").where("thread_id=? and status=2",thread_id).order(:pdate).limit(per_page)
	end
  end

  #===============================
  # Private methods for Post
  #===============================

  private

  # before save function
  def prep_post
	self.pdate = Time.now if (self.id.nil?)
	self.status = 2
  end

  def self.offset(page, per_page)
	per_page * (page - 1)
  end



end
