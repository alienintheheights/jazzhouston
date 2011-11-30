###############################
# Search class
#
# Andrew, 3/2011
################################

class SearchController < ApplicationController

    include AuthenticatedSystem
    include ExtjsRails


    @@per_page=20

    ################################
    # ACTIONS
    ################################

    # the index page
    def index
	@page_title="Site Search"
    end

    #########################################
    # EXT-JS JSON Happy AJAX Search
    #########################################
    def search_users_ext
        @search_term=params[:query]
        @users = User.find(:all,:select=>"username, first_name, last_name, user_id",
                :order=>"last_name",
                :conditions=>"lower(username) like lower('%"+@search_term+"%') or lower(first_name) like lower('%"+@search_term+"%') or  lower(last_name) like  lower('%"+@search_term+"%')")
        render :json => to_ext_json(@users)
    end

    #########################################
    # EXT-JS JSON Happy AJAX Search
    #########################################
    def search_articles_ext
        @search_term=params[:query]
        @words = Content.find(:all,:select=>"content_id, title, teaser, author, display_date",
                :order=>"display_date desc",
                :conditions=>"status_id=2 and lower(title) like lower('%"+@search_term+"%') or lower(teaser) like lower('%"+@search_term+"%') or lower(author) like  lower('%"+@search_term+"%')")
        render :json => to_ext_json(@words)
    end

    #########################################
    # EXT-JS JSON Happy AJAX Search
    #########################################
    def search_forums_ext
        @search_term=params[:query]
        @users = Threads.find(:all,:select=>"title, user_id",
                :order=>"last_name",
                :conditions=>"lower(title) like lower('%"+@search_term+"%') or lower(user_id) like lower('%"+@search_term+"%') ")
        render :json => to_ext_json(@users)
    end


end
