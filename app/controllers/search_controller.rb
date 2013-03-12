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
        @search_term = "%#{params[:query].downcase}%"
        @users = User.where("lower(username) like ? or lower(first_name) like ? or lower(last_name) like ? ", @search_term, @search_term, @search_term).order("last_name").select("username, first_name, last_name, user_id")
        render :json => to_ext_json(@users)
    end

    #########################################
    # EXT-JS JSON Happy AJAX Search
    #########################################
    def search_articles_ext
        @search_term = "%#{params[:query].downcase}%"
        @words = Content.where("status_id=2 and lower(title) like ? or lower(teaser) like ? ", @search_term, @search_term).order("display_date desc").select("content_id, title, teaser, author, display_date")
        render :json => to_ext_json(@words)
    end

    #########################################
    # EXT-JS JSON Happy AJAX Search
    #########################################
    def search_forums_ext
        @search_term = "%#{params[:query].downcase}%"
        @posts = ForumThread.where("lower(title) like ? ", @search_term).order("modified_date DESC").select("title")
        render :json => to_ext_json(@posts)
    end


end
