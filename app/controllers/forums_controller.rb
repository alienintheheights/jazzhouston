################################
# Forum class
#
# Andrew, 1/2009
# UPDATED: for Rails 3 app, 11/2011
################################

class ForumsController < ApplicationController

  include ExtjsRails

  # H-TOWN Timezone
  @@TZ='Central Time (US & Canada)'

  # TODO: make boards a class var?
  @@moderation_mode = false
  @@per_page = 15
  @@message_threshold = -6

  before_filter :login_required, :only =>[:hidepost]

  ################################
  # ACTIONS
  ################################


  ################################
  # GET /forums
  ################################
  def index
    Time.zone = @@TZ
    page_number = params[:page]
    @totalPosts = Message.count(:all)
    if (page_number)
      @page = page_number.to_i
      offset = getOffset(@page)
      @threads = ForumThread.where("status=2").order("threads.modified_date desc").includes(:user).select("users.user_id, users.username,users.image_url, threads.*").limit(@@per_page).offset(offset)
    else
      @threads = ForumThread.where("status=2").order("threads.modified_date desc").includes(:user).select("users.user_id, users.username,users.image_url, threads.*").limit(@@per_page)
      @page = 1
    end
    @ban_list = (logged_in? && session[:user_bans])?  session[:user_bans] : {}
    @page_title = "Forums"
    @boards = Board.find(:all, :conditions=>"status=2", :order=>:sort_order)
    @pp = @@per_page
    # super power to edit live threads
    @admin_mode = (params[:admin] && logged_in? && current_user.admin_flag==1)
    respond_to do |format|
      format.html {render :template => "forums/threads.erb"}
      format.mobile {render :template => "forums/index_mobile.erb"}
      format.json {render :json => @threads.to_json(:include =>{ :user => { :only => [:user_id, :url, :first_name, :last_name, :username, :image, :image_url] } })  }
    end
  end

  ################################
  # GET /forums/threads/<BOARD_ID>
  #
  #
  ################################
  def threads

    Time.zone = @@TZ
    @board = Board.find(params[:id])
    page_number = params[:page]
    @totalPosts = Message.count(:all)
    if (@board)
      @ban_list = (logged_in? && session[:user_bans])?  session[:user_bans] : {}

      if (page_number)
        @page = page_number.to_i
        offset = getOffset(@page)
        @threads = ForumThread.where("board_id=? and status=2", params[:id]).includes(:user).order("modified_date desc").limit(@@per_page).offset(offset)
      else
        @threads = ForumThread.where("board_id=? and status=2", params[:id]).includes(:user).order("modified_date desc").limit(@@per_page)
        @page = 1
      end

      @page_title="Forums | #{@board.title}"
    end
    @boards=Board.where("status=2").order(:sort_order)
    @pp = @@per_page
    # super power to edit live threads
    @admin_mode = (params[:admin] && logged_in? && current_user.admin_flag==1)
    respond_to do |format|
      format.html {render :template => "forums/threads.erb"}
      format.mobile {render :template => "forums/threads_mobile.erb"}
      format.json {render :json => @threads.to_json(:include =>{ :user => { :only => [:user_id, :url, :first_name, :last_name, :username, :image, :image_url] } })  }
    end
  end

  ################################
  # GET /forums/messages/<THREAD_ID>
  ################################
  def messages

    Time.zone = @@TZ
    pageNumber = params[:page]
    @fpage = params[:fpage]
    @thread = ForumThread.find(params[:id])
    @boards=Board.find(:all, :conditions=>"status=2", :order=>:sort_order)

    if (@thread)
      @ban_list= (logged_in? && session[:user_bans])?  session[:user_bans] : {}
      @board=Board.find(@thread.board_id)
      total_posts=@thread.post_count.to_i
      @last_page=Integer((total_posts-1)/@@per_page)+1
      @pp=@@per_page
      if (pageNumber)
        @page=pageNumber.to_i
        offset=getOffset(@page)
        @messages=Message.includes(:user).select("users.user_id, users.username, users.image_url, messages.*").where("thread_id=? and status=2",params[:id]).order(:pdate).limit(@@per_page).offset(offset)
      else
        @messages=Message.includes(:user).select("users.user_id, users.username, users.image_url, messages.*").where("thread_id=? and status=2",params[:id]).order(:pdate).limit(@@per_page)
      end

      @page_title="#{@board.title} | #{@thread.title}"
    end

    respond_to do |format|
      format.html {render :template => "forums/messages.erb"}
      format.mobile {render :template => "forums/messages_mobile.erb"}
      format.json {render :json => @messages.to_json(:include =>{ :user => { :only => [:user_id, :url, :first_name, :last_name, :username, :image, :image_url] } })  }
    end
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
      scores = MessageScore.where("user_id=? and message_id=?",current_user.user_id, message_id)
      message= Message.find(message_id)
      data={}
      if (!scores || scores.length==0)
        message.rating=message.rating+incr_value
        message.save!
        data["alert"]="message rating updated!"
        data["success"]=1

        new_score = MessageScore.new()
        new_score.user_id=current_user.user_id
        new_score.message_id=message_id
        new_score.save!
      else
        data["alert"]="you've already voted on this message!"
        data["success"]=0
      end

      data["score"]=message.rating
      data["author"]=message.user.username
      data["hide"]=(message.rating<=@@message_threshold) ? 1 : 0
      data["reopen"]=(message.rating-incr_value<=@@message_threshold) ? 1 : 0
      render :json => data
    end



  end

  def forum_topics
    # TODO: add sanitize param & request Url check!
    offset = params[:query]  || 0
    results = ForumThread.includes(:user).where("status=2").order("threads.modified_date desc").limit(@@per_page).offset(offset)

    render :json => to_ext_json(results)
  end

  def forum_messages
    # TODO: add sanitize param & request Url check!
    offset = params[:query]  || 0
    results = ForumThread.includes(:user).where("status=2").order("threads.modified_date desc").limit(@@per_page).offset(offset)

    render :json => to_ext_json(results)
  end

  # rss feed
  def rss
    response.headers["Content-Type"] = "application/rss+xml; charset=utf-8"
    @curTime = Time.now
    @threads = ForumThread.find(:all, :include=>:user, :select=>"users.user_id, users.username,users.image_url, threads.*",:conditions=>"status=2", :order=>"threads.modified_date desc", :limit=>@@per_page)
    @pp = @@per_page
    render :layout=> false
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

  ################################
  # GET /forums/new
  #
  # requires login
  ################################
  def new
    @page_title="Forum | New Post"
    @boards = Board.find(:all, :conditions=>"status=2", :order=>:sort_order)
    @board = nil
    @board_id = 0
    if (params[:board_id])
      @board = Board.find(params[:board_id])
      @board_id = @board.board_id
    end
    if logged_in? && request.post?

      thread = ForumThread.new()
      thread.title = params[:title]
      thread.board_id = @board_id
      thread.post_count = 1
      thread.modified_date = Time.now
      thread.user_id = current_user.user_id
      thread.author = current_user.username
      thread.monologue_flag = 1
      thread.status= (@@moderation_mode) ? 1 : 2
      thread.save!

      message = Message.new(params[:message])
      message.user_id = current_user.user_id
      message.thread_id = thread.thread_id
      message.author = current_user.username
      message.ip_address = request.remote_ip()
      message.status = (@@moderation_mode) ? 1 : 2
      message.pdate = Time.now
      message.save!


      redirect_to :action=>"index"
    end


  rescue Exception => exception
    puts exception.message
    flash[:notice]="Unable to post topic "
    redirect_to :action=>"threads", :id=>@board_id
  end


  ################################
  # GET /forums/reply
  #
  # requires login
  ################################
  def reply
    board=Board.find(params[:board_id])
    if logged_in? && request.post?

      message = Message.new(params[:message])
      message.user_id=current_user.user_id
      message.author=current_user.username
      message.ip_address=request.remote_ip()
      message.status= (@@moderation_mode) ? 1 : 2
      message.pdate=Time.now
      message.save!

      thread = ForumThread.find(message.thread_id)
      thread.post_count=thread.post_count+1
      # bump protection
      if (current_user.user_id!=thread.user_id)
        thread.modified_date=Time.now
        thread.user_id=current_user.user_id
        thread.author=current_user.username
        thread.monologue_flag=0
      end

      thread.save!
    end
    redirect_to :action=>"index"

  rescue Exception => exception
    puts exception.message
    flash[:notice]="Unable to post reply "
    redirect_to :action=>"threads", :id=>board.board_id

  end

  def hidepost
    if logged_in? && current_user.user_id == 1
      thread_id = params[:id]
      thread = ForumThread.find(thread_id)
      thread.status=0
      thread.save!
    end
    redirect_to :action=>"index"
  end

  private

  def getOffset(pageNumber)
    offset=@@per_page  * (pageNumber-1)
  end

end

