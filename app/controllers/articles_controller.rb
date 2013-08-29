###############################
# Content class
# references table Content
# 1:to:1 relations to Users
#
# Andrew, 10/2008
################################

class ArticlesController < ApplicationController

  include AuthenticatedSystem
  include ExtjsRails

  before_filter :login_required, :only =>[:update, :create, :destroy, :workflow, :new, :edit, :workflow]

  @@sections = {
		  1=>"Headlines",
		  3=>"Opinions",
		  5=>"Concerts and Interviews",
		  6=>"Reviews"
  }

  @@per_page=10

  ################################
  # ACTIONS
  ################################

  # the index page
  def index
	@section_id = (params[:type].nil?) ? 1 : params[:type].to_i
	@page_title = @@sections[@section_id]
	if (@page_title.nil?)
	  @section_id = 1 # default value
	  @page_title = @@sections[@section_id]
	end
	@page =       (params[:page].nil?) ? 1 : params[:page].to_i
	offset =      get_offset(@page) || 0
	total_posts = Content.count(:all, :conditions => ["content_type_id=? and status_id=2",@section_id])
	@total_pages= (total_posts/@@per_page).to_i  + 1

	@articles =   Content.find(:all, :order=>"display_date desc", :conditions => ["content_type_id=? and status_id=2",@section_id], :limit=>@@per_page, :offset=>offset)

	respond_to do |format|
	  format.html {render :template => "articles/index.erb"}
	  format.mobile {render :template => "articles/index_mobile.erb"}
	end
  end

  # article pages
  def words
	article_id = params[:id]
	if !Content.exists?(article_id)
	  @article =  Content.find_by_sub_title(article_id)
	else
	  @article  = Content.find(article_id)
	end
	@page_title = @article.title
	@section_id = (params[:type].nil?)? 1 : params[:type].to_i
	@section_title=@@sections[@section_id]
	@page =       (params[:page].nil?) ? 1 : params[:page].to_i
	if @article.status_id == 0 || (@article.status_id == 1 && !(logged_in? && current_user.editor_flag == 1))
	  redirect_to :action => "index", :type=>@section_title
	end
	respond_to do |format|
	  format.html {render :template => "articles/words.erb"}
	  format.mobile {render :template => "articles/words_mobile.erb"}
	end

  end

  # an index of review articles (i.e., content_type_id=6)
  def reviews
	redirect_to :action=>"index", :type=>6
  end

  # an index of editorial articles (i.e., content_type_id=3)
  def opinions
	redirect_to :action=>"index", :type=>3
  end

  # an index of concert review and interview articles (i.e., content_type_id=5)
  def artists
	redirect_to :action=>"index", :type=>5
  end

  # reviews pages
  def review
	words()
  end

  def search_articles_url_ext
	search_term = "%#{params[:query].downcase}%"
	results = Content.where("status_id=2 and lower(sub_title) = lower(?)", search_term)
	render :json => to_ext_json(results)
  end


  # the index page
  def workflow

	@page_title="Story Workflow"
	@live=Content.find(:all, :order=>"content_id desc", :conditions => ["status_id=2"],:limit=>10)
	@working=Content.find(:all, :order=>"content_id desc", :conditions => ["status_id=1"])

  end


  # featured headline
  def featured
	# featured
	@words=Content.find(:first, :conditions => { :featured_flag => 1 })
	render :layout=>false
  end


  # rss feed
  def rss
	response.headers["Content-Type"] = "application/rss+xml; charset=utf-8"
	@curTime = Time.now
	@articles=Content.find(:all, :order=>"display_date desc", :conditions => "status_id=2", :limit=>10)
	render :layout=> false
  end


  # ajax rotate call
  def rotate
	@articles=Content.find(:all, :conditions=>"status_id=2",:order=>"display_date desc", :limit=>10)
	headline_data =  Hash[:success=>true, :items=>@articles.length, :articles=>@articles]
	list = []
	list << headline_data

	response = {}
	response["data"] = list

	render :layout=> false, :json => response.to_json
  end



  ################################
  # Write Methods
  ################################

  # GET /news/1/edit
  def edit
	@content = Content.find(params[:id])
  end

  # PUT /contents/1
  def update
	@content = Content.find(params[:id])
	@content.update_attributes(params[:content])
	respond_to do |format|
	  format.html { redirect_to :content=>@content, :action=>"edit", :id=>@content.content_id    }
	end
  end


  def new
	@content = Content.new
  end

  # POST /contents
  # POST /contents.xml
  def create
	@content = Content.new(params[:content])
	@content.save
	respond_to do |format|
	  flash[:notice] = 'Article was successfully created.'
	  format.html {redirect_to :content=>@content, :action=>"words", :id=>@content.content_id  }
	end
  end

  # DELETE /news/1
  # DELETE /news/1.xml
  def destroy
	@content = Content.find(params[:id])
	@content.destroy

	respond_to do |format|
	  format.html { redirect_to(@content) }
	  format.xml  { head :ok }
	end
  end


  ################################
  # UTILITIES
  ################################

  def get_offset(page_number)
	@@per_page  * (page_number-1)
  end

end
