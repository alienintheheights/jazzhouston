class MusiciansController < ApplicationController
  attr_accessor :password
  include ExtjsRails

  @@per_page = 18
  @@default_inst = "saxophone"

  def index
	@page_title="Musicians"
	redirect_to(:controller => '/musicians', :action => 'byinst', :id=>@@default_inst)
  end


  def byinst
	@instrument = params[:id]

	page_number = params[:page]
	@page = (page_number)? page_number.to_i : 1
	offset = @@per_page  * (@page-1)
	@total_players = total_players_by_instrument()

	@page_title="Players by Instrument | #{params[:id]}"
	@page_size = @@per_page

	respond_to do |format|
	  format.html # index..erb
	  format.mobile {render :template => "/musicians/byinst_mobile.erb"}
	end


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

  private

  helper_method :instruments, :players
  def instruments
	@instruments ||= Instrument.all(:order=>"instrument_name")
  end

  def players
	page_number = params[:page]
	@page = (page_number)? page_number.to_i : 1
	offset = @@per_page  * (@page-1)

	@players ||= User.find(:all,
						   :include=>:instruments,
						   :conditions=>["local_player_flag=1 and (last_name is not null and last_name <>'') and (cell_phone <>'' || home_phone <>'' || url <>'') and (image is not null and image<>'') and instruments.instrument_name=?",params[:id]],
						   :order =>"last_name", :limit=>@@per_page, :offset=>offset  )

  end

  def total_players_by_instrument
	hits = User.find(:all,
							   :include=>:instruments,
							   :conditions=>["local_player_flag=1 and (last_name is not null and last_name <>'') and  (cell_phone <>'' || home_phone <>'' || url <>'')  and (image is not null and image<>'') and instruments.instrument_name=?",params[:id]]
							   )
	hits.length
  end


end
