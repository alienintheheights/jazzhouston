class ArticleServiceable
  include ExtjsRails


  def initialize(params, session)
    @params = params
    @session = session

    # Section Names (TODO relocate to constants)
    @sections = {
        1=>'Headlines',
        3=>'Opinions',
        5=>'Concerts and Interviews',
        6=>'Reviews'
    }
    @per_page=10
  end

  # Gets the title from the section array
  def title(section_id)
    @sections[section_id || 1]
  end

  # Lists the articles
  def list(section_id)
    page =       (@params[:page].nil?) ? 1 : @params[:page].to_i
    Content.where('content_type_id=? and status_id=2', section_id).order('display_date desc').page(page).per_page(@per_page)

  end

  # Loads an Article
  def load(article_id)
    if Content.exists?(article_id)
      article  = Content.find(article_id)
    else
      article =  Content.find_by_sub_title(article_id)
    end
    article
  end

  # Checks the status of an article
  def is_viewable?(article)
    if article.status_id == 0 ||
        (article.status_id == 1 && is_editor)
    end

  end

  # Search Articles, return JSON
  def search(search_term)
    results = Content.where('status_id=2 and lower(sub_title) = lower(?)', search_term)
    to_ext_json(results)
  end

  private

  # Page util
  def get_offset(page_number)
    @per_page  * (page_number-1)
  end


end