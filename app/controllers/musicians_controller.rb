class MusiciansController < ApplicationController
  attr_accessor :password
  include ExtjsRails

  @@per_page = 25

  def index
    @instruments = Instrument.all(:order=>"instrument_name")
    @page_title="Musicians"

    respond_to do |format|
      format.html # index..erb
      format.mobile {render :template => "musicians/index_mobile.erb"}
    end
  end

  def byinst
    @instrument = params[:id]
    @total_players = User.count(:all,
                         :include=>:instruments,
                         :conditions=>["local_player_flag=1 and (last_name is not null and last_name <>'') and instruments.instrument_name=?",params[:id]])

    page_number = params[:page]
    @page = (page_number)? page_number.to_i : 1
    offset = @@per_page  * (@page-1)

    @players = User.find(:all,
                         :include=>:instruments,
                         :conditions=>["local_player_flag=1 and (last_name is not null and last_name <>'') and instruments.instrument_name=?",params[:id]],
                         :order =>"last_name", :limit=>@@per_page, :offset=>offset  )


    @page_title="Players by Instrument | #{params[:id]}"
    @page_size = @@per_page
  rescue Exception=> e
    render :text => "error running query " + e.message
  end


  def profile
    @musician = User.find_by_username(params[:id])
    if (!@musician)
      @musician = User.find(params[:id])
      redirect_to(:controller => '/musicians', :action => 'profile', :id=>@musician.username)
    end
    @instruments = @musician.instruments
    @isaplaya=false
    if (@instruments)
      @isaplaya=true
    end
    @page_title="Musician Profile | #{@musician.first_name} #{@musician.last_name}"
  end

  def vcard
    @musician = User.find(params[:id])
    if (@musician)
      if @musician.last_name.nil?
        @musician.last_name = ""
      end
      vname = "jazzhouston-"+ @musician.last_name + "-" + @musician.first_name + "-vcard.vcf"
      @fullname = @musician.first_name.gsub( %r{</?[^>]+?>}, '' ) + " " + @musician.last_name.gsub( %r{</?[^>]+?>}, '' )

      headers["Content-Type"]="text/x-vcard; charset=utf-8"
      headers["Content-Disposition"]="attachment; filename="+vname
    end
    respond_to do |format|
      format.html { render :layout=> false }
    end
  end

  # extjs happy json search
  def search_ext
    @search_term=params[:query]
    @musicians= User.find(:all,:select=>"username, first_name, last_name, user_id",
                          :order=>"last_name",
                          :conditions=>"local_player_flag=1 and (lower(first_name) like lower('%"+@search_term+"%') or lower(last_name) like lower('%"+@search_term+"%'))")

    render :json => to_ext_json(@musicians)


  end


end
