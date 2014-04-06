class MusiciansController < ApplicationController

  @@per_page = 18

  # Redirects to /byinst with a random id
  def index
	@page_title="Musicians"
	# fetch random instrument
	redirect_to(:controller => 'musicians', :action => 'byinst', :id=>random_instrument.instrument_id)
  end

  # Lists musicians by selected instrument
  def byinst
	unless params[:id]
	  redirect_to "/musicians/index"
	  return
	end

	 # handle legacy by-name requests
	if params[:id].is_a?(String)
	  inst_by_name = Instrument.find_by_instrument_name(params[:id])
	  if inst_by_name
		params[:id] = inst_by_name.instrument_id
	  end
	end

	@total_players = total_players_by_instrument
	@page = (params[:page])? params[:page].to_i : 1
	@page_title=(mobile_request?) ? instrument.instrument_name : "Players by Instrument | #{instrument.instrument_name}"
	@page_size = @@per_page

	@page_id = "musicianSearch"

	respond_to do |format|
	  format.html
	  format.json {render :json => players.to_json( :only => [:user_id, :url, :first_name, :last_name, :cell_phone, :home_phone, :email, :username, :image, :image_url] ) }
	  format.mobile {render :template => "/musicians/byinst_mobile.erb"}
	end
  end


  # JSON XHR Requests from byinst search form
  def search
	search_term = "%#{params[:query].downcase}%"
	# if using search engine
	# musicians = User.search search_term, :conditions => { :local_player_flag => 1 }, :order => :last_name

	# SQL Search (to be replaced by search engine, depends on hosting situation)
	musicians = User.where("local_player_flag=1 and status_id<>1 and (cell_phone is not null or home_phone is not null) and (lower(username) like ? or lower(first_name) like ? or lower(last_name) like ? )", search_term, search_term, search_term).order("last_name").select("username, first_name, last_name, user_id, cell_phone, url, home_phone, image, image_url")

	# JSON output
	render :json => musicians
  end

  def list_instruments
	render :json => instruments
  end


  # Legacy vcard
  def vcard
	@musician = User.find(params[:id])
	if @musician
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

  private

  helper_method :instruments, :instrument, :players

  def random_instrument
	# 14 = max searchable ID = HACK!
	@random_instrument ||=  Instrument.where("instrument_id<14").sample(1).first
  end

  def instrument
	@instrument ||= Instrument.find(params[:id])
  end

  def instruments
	@instruments ||= Instrument.order("instrument_group, instrument_name").all()
  end

  def players
	offset = @@per_page  * (@page-1)

	@players ||= User.includes(:instruments).select("user_id, first_name, last_name, username, image, home_phone, cell_phone, url, email").where("(last_name is not null and last_name <>'') and (cell_phone <>'' || home_phone <>'' || url <>'') and (image is not null and image<>'') and instruments.instrument_id=?",params[:id]).order("last_name").limit(@@per_page).offset(offset)

  end

  def total_players_by_instrument
	hits = User.find(:all,
					 :include=>:instruments,
					 :conditions=>["(last_name is not null and last_name <>'') and  (cell_phone <>'' || home_phone <>'' || url <>'')  and (image is not null and image<>'') and instruments.instrument_id=?",params[:id]]
	)
	hits.length
  end


end
