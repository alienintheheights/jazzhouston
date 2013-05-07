class Topic < ActiveRecord::Base

  set_primary_key "thread_id"
  set_table_name "threads"

  belongs_to :forum_board
  belongs_to :user

  has_many :posts, :foreign_key => "thread_id", :order => "messages.pdate", :dependent => :destroy do
	def page(limit=10, offset=0)
	  all(:limit=> limit, :offset=>offset)
	end
  end

  # bulk update-able
  attr_accessible :board_id, :title, :modified_date, :status, :post_count, :user_id, :posts_attributes

  accepts_nested_attributes_for :posts


  validates_presence_of :board_id, :title

  before_save :prep_topic

  # to_string method
  def to_s
	"Topic: board_id=>#{board_id}, title=>#{title}, thread_id=>#{thread_id}, posts=>#{posts}"
  end


  #===============================
  # Class methods for Topic
  #===============================

  @@max_per_page  = 50


  def self.fetch_thread(thread_id)
	Topic.where("threads.thread_id=? and messages.status=2", thread_id).includes(:posts, :user).first # only one row for threads
  end

  # fetches most recent posts
  def self.recent_posts(page_number, per_page = @@max_per_page, sort_by =  "threads.modified_date desc")

	page = page_number.to_i || 1
	offset = Topic.offset(page, per_page)
	Topic.where("status=2").order(sort_by).includes(:user).select("users.user_id, users.username,users.image_url, threads.*").limit(per_page).offset(offset).all

  end

  # fetches most recent posts by board
  def self.recent_posts_by_id(board_id, page_number, per_page = @@max_per_page, sort_by =  "threads.modified_date desc")

	page = page_number.to_i || 1
	offset = Topic.offset(page, per_page)

	if !board_id || board_id == 0
	  return Topic.recent_posts(page_number, per_page, sort_by)
	end

	Topic.where("board_id=? and status=2", board_id).includes(:user).order("modified_date desc").limit(per_page).offset(offset).all

  end



  #===============================
  # Private methods for Topic
  #===============================

  private

  def self.offset(page, per_page)
	(page>=1) ? per_page  * (page-1) : 0
  end

  # before_save method
  def prep_topic
	self.modified_date = Time.now
	self.post_count = self.post_count + 1
	self.status = 2
  end


end
