################################
# Forum class
#
# Andrew, 1/2009
# UPDATED: for Rails 3 app, 11/2011
# REFACTORED: 4/2013
#################################

class ForumsController < ApplicationController

  before_filter :login_required, :only =>[:hidepost]
  before_filter :forum_member, :only =>[:create, :update]

  def forum_member
	logged_in? && request.post? ? true : access_denied
  end

  # H-TOWN Timezone
  @@time_zone = 'Central Time (US & Canada)'
  @@moderation_mode = false
  @@per_page = 20
  @@message_threshold = -6

  ################################
  # ACTIONS
  #
  ################################


  ################################
  # GET /forums
  ################################
  def index
	if params[:id].nil? || params[:id]==0
	  create_recent()
	end

	# respond
	respond_to do |format|
	  format.html {render :template => "forums/index.erb"}
	  format.mobile {render :template => "forums/index_mobile.erb"}
	  # for RSS feed
	  format.xml {render :template => "forums/rss.erb"}
	  # .json is used by mobile web service/REST calls (iOS in particular)
	  format.json {render :json => @forum_board.topic_list.to_json(:include =>{ :user => { :only => [:user_id, :url, :first_name, :last_name, :username, :image, :image_url] } })  }
	end
  end

  ################################
  # GET /forums/threads/<BOARD_ID>
  ################################
  def threads
	# TODO update routes.rb and remove this
	redirect_to :action=>"index", :id=>params[:id]
  end


  ################################
  # GET /forums/new
  #
  # requires login
  ################################
  def new
	@page_title="Forum | New Post"
	@topic = Topic.new
	@topic.posts.build
  end

  ################################
  # POST /forums/create
  # requires login
  ################################
  def create

	@topic = Topic.new( params[:topic])
	@topic.user_id = current_user.user_id
	post = @topic.posts.first
	if post
	  post.user_id = current_user.user_id
	  post.ip_address = request.remote_ip()
	end
	@topic.save

	redirect_to :action=>"index"

  end


  ##################################
  # GET /forums/messages/<THREAD_ID>
  ##################################
  def messages

	if params[:id].nil?
	  flash[:message] = "Bad URL. Try again from a working link."
	  redirect_to :action=>"index"
	  return
	end

	if topic.nil?
	  flash[:message] = "Sorry, this topic has either been removed or the link that got you here is incorrect."
	  redirect_to :action=>"index"
	  return
	end

	# board
	@board = ForumBoard.find(topic.board_id)
	if @board.nil?
	  flash[:message] = "Sorry, that post is from a forum that has been removed."
	  redirect_to :action=>"index"
	  return
	end

	respond_to do |format|
	  format.html {render :template => "forums/messages.erb"}
	  format.mobile {render :template => "forums/messages_mobile.erb"}
	  # .json is used by mobile web service/REST calls (iOS in particular)
	  format.json {render :json => @topic.to_json(:include =>{ :user => { :only => [:user_id, :url, :first_name, :last_name, :username, :image, :image_url] } })  }
	end

  rescue Exception => exception
	flash[:message] = "Sorry, that post is from a forum that has been removed."
	redirect_to :action=>"index"

  end



  ################################
  # GET /forums/reply
  #
  # requires login
  ################################
  def update

	# create new Post
	post = Post.new(params[:post])
	post.user_id = current_user.user_id
	post.ip_address = request.remote_ip()
	# fetch topic
	@topic = Topic.find(post.thread_id)
	@topic.user_id = post.user_id

	# add post to topic
	@topic.posts.push(post)
	@topic.save

	redirect_to :action=>"index"

  end

  ################################
  # AJAX call for forum vote
  #
  ################################
  def vote
	if (!logged_in?)
	  data={}
	  data["alert"]="You must be logged in to vote."
	  data["success"]=0
	  render :json => data
	  return
	end

	incr_value= (params[:mode]=="UP") ? 1: -1
	message_id = params[:id]
	if (message_id)
	  # check for existing vote
	  message = MessageScore.vote(current_user.user_id, message_id, incr_value)
	  data={}
	  if message.nil?
		data["alert"]="you've already voted on this message!"
		data["success"]=0
	  else
		data["success"]=1
		data["score"] = message.rating
		data["author"] = message.user.username
		data["hide"] = (message.rating <= @@message_threshold)
		data["reopen"] = (message.rating - incr_value <= @@message_threshold)
	  end
	  render :json => data
	end

  end


  # rss feed
  # used by twitter feed
  def rss
	response.headers["Content-Type"] = "application/rss+xml; charset=utf-8"
	# TODO update routes.rb and remove this
	redirect_to :action=>"index", :id=>params[:id], :format=>"xml"
  end


  ################################
  # GET /forum/ban_list
  #
  # requires login
  ################################
  def ban_list

	if !logged_in?
	  redirect_to :action=>"index"
	  return
	end

	if request.post?

	  if (params[:mode]=="delete")

		banned_user=UserBan.find(:all, :conditions=>["victim_id=? and pariah_id=?",current_user.user_id, params[:pariah_id]])
		if (banned_user && banned_user.length>0)
		  for ban in banned_user
			ban.destroy
		  end

		  if (session[:user_bans])
			session[:user_bans].delete(params[:pariah_id])
		  end

		  flash[:notice]=params[:pariah_name]+" ban removed. You should logout and back in again."
		else
		  flash[:notice]=params[:pariah_name]+" is not on your ban list"
		end


	  elsif (params[:mode]=="add")

		skip_flag=false
		if (session[:user_bans])
		  if (session[:user_bans].has_key?(params[:pariah_id]) )
			flash[:notice]=params[:pariah_name]+" is already on your ban list"
			skip_flag=true
		  end
		end

		if !skip_flag
		  banned_user=UserBan.new
		  banned_user.victim_id=current_user.user_id
		  banned_user.pariah_id=params[:pariah_id]
		  banned_user.save!

		  user_bans=UserBan.find(:all, :conditions=>["victim_id=?",current_user.user_id])
		  if (user_bans)
			ban_list={}
			for victim in user_bans
			  ban_list[victim.pariah_id]={}
			end
			session[:user_bans]=ban_list
		  end

		  flash[:notice]=params[:pariah_name]+" is now on your ban list. You should logout and back in again."
		end
	  end

	end

	@bans=UserBan.find(:all, :include=>:user,:select=>"users.user_id, users.username,user_bans.*", :conditions=>["victim_id=?",current_user.user_id])

	@page_title="Forum | Ignore User Service"


  end

  def hidepost
	if logged_in? && current_user.user_id == 1
	  thread_id = params[:id]
	  thread = Topic.find(thread_id)
	  thread.status=0
	  thread.save!
	end
	redirect_to :action=>"index"
  end


  private

  helper_method :topic, :board_list, :board, :page_vars, :topic_list


  def board_list
	@board_list ||= ForumBoard.where("status=2").all
  end

  def board
	@board ||= ForumBoard.find(params[:id])
  end

  def topic_list
	page_number = (params[:page] || 1).to_i
	@topic_list ||= Topic.recent_posts_by_id(board.board_id, page_number, @@per_page)
  end


  def topic
	@topic ||= Topic.fetch_thread(params[:id] || 0)
  end


  # add view-centric variables for messages
  # assumes topic and board have been defined
  def page_vars
	@page_vars = {}
	if params[:action] == "messages"  && !topic.nil?
	  @page_vars.merge!({
								:page_title => "#{board.title} | #{topic.title}",
								:last_page => Integer((topic.post_count.to_i - 1)/@@per_page) + 1,
								:total_posts => topic.post_count.to_i,
								:board_title => (board) ? board.title : "",
								:orig_page_number => params[:fpage] || 1
						})
	end
	# add view-centric variables
	@page_vars.merge!({
							  :page_number => (params[:page] || 1).to_i,
							  :per_page => @@per_page,
							  :ban_list => (logged_in? && session[:user_bans]) ? session[:user_bans] : {},
							  :admin_mode => (params[:admin] && logged_in? && current_user.admin_flag==1)
					  })
  end

  def create_recent
	@board = ForumBoard.new
	@board[:board_id] = 0
	@board[:title] = "Recent"
	@board[:status] = 2
  end


end

