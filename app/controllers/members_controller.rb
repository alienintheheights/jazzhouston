#########################################
# MembersController
#
# @author: Andrew Lienhard
#########################################
class MembersController < ApplicationController


  include AuthenticatedSystem
  include ExtjsRails
  require "RMagick"
  include UserChallenge

  #rescue_from (ActiveRecord::RecordNotFound) { |e| render :file => 'public/404.html' }
  #rescue_from (ActiveRecord::RecordInvalid) { |e| render :file => 'public/404.html' }
  #rescue_from (NoMethodError) { |e| render :file => 'public/404.html' }

  # H-TOWN Timezone
  @@time_zone='Central Time (US & Canada)'

  # Member Messages
  @@msg=[]
  @@msg[0]="Membership Confirmed!"
  @@msg[1]="Invalid confirmation code. Check the link in the email."
  @@msg[2]="Password changed! Please login."

  def loginpage
	@page_title = "Log In Page"
  end

  #########################################
  # Login
  #########################################
  def login
	#return unless request.post?
	u = nil
	if params[:login] && params[:password]
	  u = User.authenticate(params[:login].downcase, params[:password])
	end

	if u.nil?
	  flash[:notice]="Unable to login, check your username and password"
	  redirect_to(:controller => '/members', :action => 'index')
	elsif u.status_id == 1
	  # unconfirmed user
	  u=nil # a logout
	  redirect_to(:controller => '/members', :action => 'confirmform', :id=>params[:username])
	else
	  self.current_user=u
	end

	if logged_in?
	  if params[:remember_me] == "1"
		self.current_user.remember_me
		cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
	  end
	  user_bans=UserBan.find(:all, :conditions=>["victim_id=?",current_user.user_id])
	  if user_bans
		ban_list={}
		for victim in user_bans
		  ban_list[victim.pariah_id]={}
		end
		session[:user_bans]=ban_list
	  end
	  flash[:message] = "Logged in successfully"
	  redirect_to :back,  :notice=>flash[:notice]
	end
  end



  #########################################
  # Logout
  #########################################
  def logout
	self.current_user.forget_me if logged_in?
	cookies.delete :auth_token
	reset_session
	flash[:message] = "You have been logged out."
	redirect_to :back,  :message=>flash[:message]
  end



  #########################################
  # Members Home Page
  #########################################
  def index
	@page_title="Members Home"
	@users = User.find(:all, :conditions=>"status_id=0", :order=>"user_id desc", :limit=>20)

	if params[:msgid]
	  flash[:notice]=@@msg[params[:msgid].to_i]
	end
	if logged_in?
	  @user = User.find(self.current_user.user_id)
	end

	respond_to do |format|
	   format.html  {render :template => "members/index.erb"}
	  format.mobile {render :template => "members/index_mobile.erb"}
	end
  end


  #########################################
  # Profile Page
  #########################################
  def profile
	#unless read_fragment({})

	@member = User.find_by_username(params[:id].downcase)
	if !@member
	  @member = User.find(params[:id])
	  if @member.nil?
		 flash[:notice] = "This account does not exist."
	  	 redirect_to :action => 'index'
	  	 return
	  end
	end
	if @member.status_id==1
	  flash[:notice] = "This account is still awaiting user confirmation."
	  redirect_to :action => 'index'
	  return
	end
	@instruments = @member.instruments
	@isaplaya = (@instruments && @instruments.length>0)

	if @member.local_player_flag==1
	  @shows = Event.find(:all, :order=>"event_type_id, show_date",  :conditions=>["artist_id=? and (event_type_id=2 OR show_date>=?)",@member.user_id,Date.today-1], :limit=>15)
	end

	if (@member.editor_flag)
	  @articles=Content.find(:all, :conditions=>["author_id=? and status_id=2",@member.user_id], :order=>"display_date desc", :limit=>10)
	end

	@page_title="Member Profile | #{@member.username}"
	#end
	respond_to do |format|
	  format.html  {render :template => "members/profile.erb"}
	  format.mobile {render :template => "members/profile_mobile.erb"}
	  format.json {render :json =>@member}
	end


  rescue Exception => exception
	flash[:notice] = "Sorry, our servers exploded."
	redirect_to :action=>"members/index.erb"

  end


  #########################################
  # Post-Create Page
  #########################################
  def newuser
	@page_title="Members | Thanks for Signing Up!"

  end


  #########################################
  # Confirm Form
  #########################################
  def confirmform

	if request.post?
	  @user = User.find_by_username(params[:username].downcase)
	  if (!@user)
		flash[:notice]="Member not found."
	  else
		flash[:notice]="Confirmation E-mail resent"
		sendconfirmation(@user)
	  end
	else
	  flash[:notice]="Please confirm your registration. Use this form to resend the E-mail."
	  @username=params[:username]
	end
	@page_title="Members | Resend Confirmation E-mail"

  end


  #########################################
  # Confirmation Action
  #########################################
  def confirm
	# need some security on this, otherwise a user could change their status
	@user = User.find_by_username(params[:username].downcase)

	if !@user
	  flash[:notice]="Invalid Username"
	  redirect_to(:controller => '/members', :action => 'index', :msgid=>1)
	  return
	end

	if @user.status_id != 1
	  flash[:notice]="This account has been already been confirmed."
	  redirect_to(:controller => '/members', :action => 'profile', :id=>@user.user_id)
	  return
	end

	if (@user.hash_key==params[:key])
	  @user.status_id=0
	  @user.save
	  # send the email
	  if Rails.env.production?
		Notifier.deliver_signup_notification(@user, "Welcome to Jazzhouston!")
	  end

	  self.current_user=@user

	  redirect_to(:controller => '/members', :action => 'index', :msgid=>0)
	else

	  redirect_to(:controller => '/members', :action => 'index', :msgid=>1)
	end

  end


  #########################################
  # Lost Password Form
  #########################################
  def sendlostpasswordemail
	if request.post?
	  @user = User.find_by_username(params[:login].downcase)
	  if (!@user)
		flash[:notice]="Member not found."
	  else
		key = @user.hash_key
		if Rails.env.production?
		  Notifier.deliver_lost_password(@user, "Password reset for jazzhouston?", key)
		end
		flash[:notice]="Your password has been sent."
	  end
	else
	  flash[:notice]="Please enter your username."
	end

  end


  #########################################
  # Reset Password Action
  #########################################
  def resetpassword
	@key=params[:key]

	# if POST
	if request.post?
	  # Validations
	  @user = User.find_by_username(params[:login].downcase)
	  if !@user
		flash[:notice]="Login not found. Try again."
		return
	  end

	  if key == @user.hash_key
		flash[:notice]="Check your email link. The key is incorrect."
		return
	  end

	  if params[:password]==params[:confirm_password]
		@user.password=params[:password]
		@user.save(false)
		# start the session
		if Rails.env.production?
		  Notifier.deliver_updated_password(@user, "Password change for jazzhouston")
		end
		# send them back to the members home page
		redirect_to(:controller => '/members', :action => 'index', :msgid=>2)
	  else
		@username=@user.username
		flash[:notice]="Password mismatch, please try again"
	  end


	else
	  flash[:notice]="Invalid request. Security check rule failure."
	  @username=params[:username]
	end


  end

  #########################################
  # Change Password Form
  #########################################
  def changepassword
	if request.post?
	  if params[:new_password] != params[:confirm_password]
		flash[:notice]="The new passwords don't match. Try again."
	  else
		u = User.change_password(params[:login], params[:old_password], params[:new_password])
		if !u
		  flash[:notice]="Invalid old password. Try again."
		else
		  flash[:notice]="Password updated!"
		  if Rails.env.production?
			Notifier.deliver_updated_password(u, "Password reset for jazzhouston")
		  end
		end
	  end
	end

	@page_title="Members | Change Your Password"
  rescue Exception => exception

	data = { :failure => 'true', :message=>exception.message}
	render :text => data.to_json, :layout => false

  end


  ####################################
  # Registration/Account Mgmt Methods
  ####################################



  #########################################
  # GET /members/new
  #########################################
  def new
	@instruments = Instrument.all(:order=>"instrument_group, instrument_name")
	@page_title="Member Profile | Sign Up!"
  end


  #########################################
  # Called by the sign-up form
  #########################################
  def create
	headers["Content-Type"] = "text/plain; charset=utf-8"
	return unless request.post?

	challenge = session["uc"]
	session["uc"] = nil

	# image challenge check
	if Rails.env.production?
	  test = challenge.checkResponse(params[:imageChallenge])
	else
	  test = true
	end
	if !test
	  data = { :failure => 'true', :message=>"Invalid Image challenge response. Try again" }
	  render :text => data.to_json, :layout => false
	  return
	end

	@user = User.new(params[:user])
	@user.status_id = 1 # requires confirmation
	# get the instruments
	user_instruments=params[:instrument]
	if user_instruments
	  instruments=[]
	  for item in user_instruments
		axe=Instrument.find(item[0])
		instruments.push(axe)
	  end
	  @user.instruments = instruments
	  @user.local_player_flag = 1
	end

	# handle poorly set URL field
	if !@user.url &&  !@user.url.blank? && @user.url !~/^http/i
	  @user.url = "http://" + @user.url
	end

	@user.save!
	flash[:success] = "Thanks for signing up!"

	# email confirmation
	sendconfirmation(@user)

	data = { :success => 'true', :message=>"Success", :user => @user.username}
	render :text => data.to_json, :layout => false

  rescue Exception => exception

	data = { :failure => 'true', :message=>exception.message}
	render :text => data.to_json, :layout => false

  end



  #########################################
  # GET /members/edit/id
  #########################################
  def edit
	valid_user = false
	if logged_in? && (self.current_user.user_id==params[:id].to_i || self.current_user.admin_flag==1)
	  @user = User.find(params[:id])
	  @page_title = "Member Profile | Editing for #{@user.username}"
	  valid_user = true
	  @instruments = Instrument.all(:order=>"instrument_group, instrument_name")
	  @myinstruments = []
	  for item in @user.instruments
		@myinstruments[item.instrument_id]=item.instrument_name
	  end
	end
	if !valid_user
	  redirect_to(:controller => '/members', :action => 'profile', :id=>params[:id])
	end


	respond_to do |format|
	  format.html # index..erb
	  format.mobile {render :template => "members/edit_mobile.erb"}
	end

  end


  #########################################
  # Upgrade user to editor
  # Admin function only
  #########################################
  def upgrade
	if logged_in? && self.current_user.admin_flag == 1
	  user = User.find(params[:id])
	  user.upgrade_account(params[:editor_flag])
	  redirect_to(:controller => '/members', :action => 'profile', :id=>params[:id])
	end
  end


  #########################################
  # Called by the /members/edit/id
  #########################################
  def update
	@user = User.find(params[:id])
	# prevent spoofs
	if !request.post? || !logged_in? || !(self.current_user.user_id == params[:id].to_i || self.current_user.admin_flag == 1)
	  puts "ERROR: Invalid request for update"
	  return
	end

	# for remote updates by admins
	if @user.password
	  @user = User.authenticate(@user.username, @user.password)
	end
	@user.update_attributes!(params[:user])

	# get the instruments
	user_instruments=params[:instrument]
	if user_instruments
	  instruments=[]
	  for item in user_instruments
		axe=Instrument.find(item[0])
		instruments.push(axe)
	  end
	  @user.instruments=instruments
	  @user.local_player_flag=1
	else
	  @user.instruments=[]
	  @user.local_player_flag=0
	end

	@user.save!
	expire_user(@user)
	render :json => {:success=>true, :message=>"Successfully updated your account", :user=>@user}


  rescue Exception => exception

	data = { :failure => 'true', :message=>exception.message}
	render :text => data.to_json, :layout => false

  end

  #####################
  # DELETE account
  #####################
  def destroy
	member = User.find(params[:id])
	if member
	  member.delete_account()
	end

	flash[:notice] = 'Your Account has been deleted'
	redirect_to(:controller => '/home', :action => 'index')

  end


  #####################
  # image upload method
  #####################
  def upload

	#if request.post?
	@user = User.find(params[:id])
	@user.update_attributes(params[:user])

	# cleanup
	if !@user.image_url.nil? && !@user.image_url.blank?
	  @user.image=nil
	elsif !@user.image.nil? && !@user.image.blank?
	  @user.image_url=nil
	end

	@user.save!
	# clear cache, if any
	expire_user(@user)

	redirect_to :action => "profile", :id => @user.username

  rescue Exception => exception
	flash[:notice]= exception

  end



  #########################################
  # EXT-JS JSON Happy AJAX Search
  #########################################
  def search_ext
	@search_term = "%#{params[:query].downcase}%"
	@users = User.search_users(@search_term)
	render :json => to_ext_json(@users)
  end

  ##############################################
  # Image: the challenge image for registration
  ##############################################
  def challenge_image
	if Rails.env.production?
	  store_path = "/home/jazzhouston/rails/jazzhouston/public/images"
	else
	  store_path = "/Users/andrew/Development/www/jazzhouston/public/images"
	end
	filename = store_path + "/camouflage.png"

	challenge = UserChallenge::SumImageChallenger.new
	session["uc"] = challenge
	send_data challenge.render(filename), :filename => "confirm.png",
			  :type => 'image/png', :disposition => 'inline'
  end


  private


  #########################################
  # Send Email
  #########################################
  def sendconfirmation(user)
	if !Rails.env.production?
	  return
	end
	subject="Please confirm your registration at Jazzhouston"
	# send the email
	Notifier.deliver_confirmation_email(user, subject, user.hash_key)
  end


  #########################################
  # Cache control
  #########################################
  def expire_user(user)
	# no caching for now
	#expire_fragment(:action => 'profile')
  end


end