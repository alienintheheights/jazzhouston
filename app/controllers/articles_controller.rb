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

  before_filter :login_required, :only =>[:update, :create, :destroy, :update_featured, :workflow, :new, :edit, :workflow]

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
    @section_id = (params[:type].nil?)? 1 : params[:type].to_i
    @page_title = @@sections[@section_id]
    if (@page_title.nil?)
      @section_id = 1 # default value
      @page_title = @@sections[@section_id]
    end
    @page =       (params[:page].nil?) ? 1 : params[:page].to_i
    offset =      getOffset(@page) || 0
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
    # TODO: add sanitize param & request Url check!
    @search_term=params[:query]
    results = Content.where("status_id=2 and lower(sub_title) = lower('?')", @search_term)
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


  # sets featured show
  def update_featured

    if request.post?

      if (params[:feature_id])

        cur_featured=Content.find(:first,:conditions=>"featured_flag=1")
        cur_featured.featured_flag=0
        cur_featured.save!

        @fwords=Content.find(params[:feature_id])
        @fwords.featured_flag=1
        @fwords.save!

        flash[:notice]="feature updated"

      end


    else
      @fwords=Content.find(:first, :conditions => { :featured_flag => 1 })
    end

    @page_title = "Set Article Feature"
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
    headlineData =  Hash[:success=>true, :items=>@articles.length, :articles=>@articles]
    list = []
    list << headlineData

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
  # PUT /contents/1.xml
  def update
    @content = Content.find(params[:id])

    respond_to do |format|
      if @content.update_attributes(params[:content])
        #flash[:notice] = 'Article was successfully updated.'
        format.html { redirect_to :content=>@content, :action=>"edit", :id=>@content.content_id   }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @content.errors, :status => :unprocessable_entity }
      end
    end
  end


  def new
    @content = Content.new
  end

  # POST /contents
  # POST /contents.xml
  def create
    @content = Content.new(params[:content])

    respond_to do |format|
      if @content.save
        flash[:notice] = 'Article was successfully created.'
        format.html {redirect_to :content=>@content, :action=>"edit", :id=>@content.content_id  }
        format.xml  { render :xml => @content, :status => :created, :location => @content }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @content.errors, :status => :unprocessable_entity }
      end
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

  # a utility to setup the auto-break articles
  def autoBreaks(str, autoOn)
    if autoOn==1
      str = str.sub(/^\r?\n/,"<br/><br/>")
      return str.sub(/^[ \t]*$\r?\n/,"<br/><br/>")
    else
      return str
    end
  end

  def getOffset(pageNumber)
    offset=@@per_page  * (pageNumber-1)
  end

end
