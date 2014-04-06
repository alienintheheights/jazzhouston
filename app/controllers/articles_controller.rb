###############################
# Content class
# references table Content
# 1:to:1 relations to Users
#
# Andrew, 10/2008
################################

class ArticlesController < ApplicationController

  include JazzhoustonAuth

  before_filter :is_editor?, :only =>[:update, :create, :destroy, :workflow, :new, :edit, :workflow]


  ################################
  # ACTIONS
  ################################

  # the index page
  def index
    serviceable = ArticleServiceable.new(params, session)

    @section_id = (params[:type].nil?) ? 1 : params[:type].to_i
    @page_title = serviceable.title(@section_id)
    @articles = serviceable.list(@section_id)
    respond_to do |format|
      format.html {render :template => 'articles/index.erb'}
      format.mobile {render :template => 'articles/index_mobile.erb'}
    end
  end

  # article pages
  def words
    serviceable = ArticleServiceable.new(params, session)
    @section_title = serviceable.title(@section_id)

    article_id = params[:id]
    @article = serviceable.load(article_id)

    @page_title = @article.title
    @section_id = (params[:type].nil?)? 1 : params[:type].to_i
    if serviceable.is_viewable?(@article)
      redirect_to :action => 'index', :type=>@section_title
    end
    respond_to do |format|
      format.html {render :template => 'articles/words.erb'}
      format.mobile {render :template => 'articles/words_mobile.erb'}
    end

  end

  # an index of review articles (i.e., content_type_id=6)
  def reviews
    redirect_to :action=>'index', :type=>6
  end

  # an index of editorial articles (i.e., content_type_id=3)
  def opinions
    redirect_to :action=>'index', :type=>3
  end

  # an index of concert review and interview articles (i.e., content_type_id=5)
  def artists
    redirect_to :action=>'index', :type=>5
  end

  # reviews pages
  def review
    words
  end

  def search_articles_url_ext
    serviceable = ArticleServiceable.new(params, session)
    search_term = '#{params[:query].downcase}'
    render :json => serviceable.search(search_term)
  end


  # the index page
  def workflow

    @page_title='Story Workflow'
    @live=Content.find(:all, :order=>'content_id desc', :conditions => ['status_id=2'],:limit=>10)
    @working=Content.find(:all, :order=>'content_id desc', :conditions => ['status_id=1'])

  end


  # rss feed
  def rss
    response.headers['Content-Type'] = 'application/rss+xml; charset=utf-8'
    @curTime = Time.now
    @articles=Content.find(:all, :order=>'display_date desc', :conditions => 'status_id=2', :limit=>10)
    render :layout=> false
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
      format.html { render :template=>'articles/edit.erb', :content=>@content, :action=>'edit', :id=>@content.content_id    }
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
      format.html {redirect_to :content=>@content, :action=>'words', :id=>@content.content_id  }
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
###########################

end
