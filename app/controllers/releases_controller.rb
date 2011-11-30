################################
# Recordings class
# references table Albums
# 1:to:1 relations to Users
#
# Andrew, 10/2008
################################

class ReleasesController < ApplicationController

    before_filter :login_required, :only =>[:update, :create]

    ################################
    # ACTIONS
    ################################

    def index

        @albums=Album.find(:all, :joins=>:genre, :select=>"genres.genre_name, albums.*",
                :order=>"release_date desc", :limit=>9)
        @page_title="Local Recordings"

	respond_to do |format|
      		format.html # index..erb
      		format.mobile {render :template => "releases/mobile.erb"}
    	end
    end

    def bygenre
	genre=Genre.find(params[:id])
	@genre_name=genre.genre_name
        @albums=Album.find(:all, :joins=>:genre, :select=>"genres.genre_name, albums.*",
                :order=>"release_date desc",:conditions => ["genres.genre_id=?",params[:id]])
        @page_title="By Genre: "+genre.genre_name
	respond_to do |format|
      		format.html # index..erb
      		format.mobile {render :template => "releases/bygenre-mobile.erb"}
    	end
    end

    def about
	@album=Album.find(params[:id], :joins=>:genre, :select=>"genres.genre_name, albums.*")
        @page_title="Local Recordings | #{@album.artist_name}: #{@album.title}"
    end

    def browse
        @albums=Album.find(:all, :joins=>:genre, :select=>"genres.genre_name, albums.*",
                :order=>"artist_name, release_date ")
        @page_title="Browse Local Recordings" 
	respond_to do |format|
      		format.html # index..erb
      		format.mobile {render :template => "releases/browse-mobile.erb"}
    	end
    end



    ################################
    # Write Methods

    ################################

    # GET /comments/new
    # GET /comments/new.xml
    def new
        @album = Album.new

        respond_to do |format|
            format.html # new.html.erb
            format.xml  { render :xml => @album }
        end
    end

    # GET /news/1/edit
    def edit
        @album = Album.find(params[:id])
    end

    # PUT /comments/1
    # PUT /comments/1.xml
    def update
        @album = Album.find(params[:id])

        respond_to do |format|
            if @album.update_attributes(params[:album])
                #flash[:notice] = 'Article was successfully updated.'
                format.html { redirect_to :album=>@album, :action=>"edit", :id=>@album.album_id   }
                format.xml  { head :ok }
            else
                format.html { render :action => "edit" }
                format.xml  { render :xml => @album.errors, :status => :unprocessable_entity }
            end
        end
    end


    # POST /news
    # POST /news.xml
    def create
        @album = Album.new(params[:album])


        respond_to do |format|
            if @album.save
                flash[:notice] = 'Article was successfully created.'
                format.html { redirect_to :album=>@album, :action=>"edit", :id=>@album.album_id   }
                format.xml  { render :xml => @album, :status => :created, :location => @album }
            else
                format.html { render :action => "new" }
                format.xml  { render :xml => @album.errors, :status => :unprocessable_entity }
            end
        end
    end

    # DELETE /news/1
    # DELETE /news/1.xml
    def destroy
        @album = Album.find(params[:id])
        @album.destroy

        respond_to do |format|
            format.html { redirect_to(@album) }
            format.xml  { head :ok }
        end
    end



end
