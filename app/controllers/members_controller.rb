#########################################
# MembersController
#
# @author: Andrew Lienhard
#########################################
class MembersController < ApplicationController

  #########################################
  # Members Home Page
  #########################################
  def index
    @page_title='Members Home'
    @users = User.where('status_id=0')
                .order('user_id desc')
                .limit(20)


    # Member Messages
    msg = [
        'Membership Confirmed!',
        'Invalid confirmation code. Check the link in the email.',
        'Password changed! Please login.'
    ]

    if params[:msgid]
      flash[:notice]=msg[params[:msgid].to_i]
    end

    if user_signed_in?
      @user = User.find(self.current_user.user_id)
    end

    respond_to do |format|
      format.html  {render :template => 'members/index.erb'}
      format.mobile {render :template => 'members/index_mobile.erb'}
    end
  end


  #########################################
  # Profile Page
  #########################################
  def profile
    serviceable = MemberServiceable.new(params, session)
    @member = serviceable.load

    @page_title="Member Profile | #{@member.username}"

    respond_to do |format|
      format.html  {render :template => 'members/profile.erb'}
      format.mobile {render :template => 'members/profile_mobile.erb'}
      format.json {render :json =>@member}
    end

  end


  #########################################
  # GET /members/edit/id
  #########################################
  def edit
    valid_user = false
    if user_signed_in? && (self.current_user.user_id==params[:id].to_i || self.current_user.admin_flag==1)
      @user = User.find(params[:id])
      @page_title = 'Member Profile Settings'
      valid_user = true
      @instruments = Instrument.all(:order=>'instrument_group, instrument_name')

      # array of instrument names. TODO create a scope for this on user.instruments?
      @myinstruments = []
      for item in @user.instruments
        @myinstruments[item.instrument_id] = item.instrument_name
      end
    end

    unless valid_user
      flash[:notice] = 'Oops. Snafu.  ' + valid_user.to_s + ' and id is ' + params[:id]
      redirect_to(:controller => '/members', :action => 'index', :id=>params[:id])
      return
    end

    respond_to do |format|
      format.html # index..erb
      format.mobile {render :template => 'members/edit_mobile.erb'}
    end

  end


  #########################################
  # Called by the /members/edit/id
  #TODO REST resources
  #########################################
  def update
    # prevent spoofs
    #TODO this is bullshit code; add filters, :before_update
    if !(request.post? || request.put?) || !user_signed_in? ||
        !(self.current_user.user_id == params[:id].to_i || self.current_user.admin_flag == 1)
      flash[:notice] = 'EPIC FAIL. You\'re not logged in or you\'re trying to update someone else\'s account.'
      redirect_to(:controller => '/members', :action => 'index', :id=>params[:id])
      return
    end

    serviceable = MemberServiceable.new(params, session)
    @user = serviceable.update

    flash[:message]='Account Updated.'
    redirect_to(:controller => '/members', :action => 'profile', :id=>params[:id])

  end




  #####################
  # DELETE account
  #####################
  def destroy
    member = User.find(params[:id])
    if member
      member.delete_account
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
    unless @user.image.blank?
      @user.image_url=nil
    end

    redirect_to :action => 'profile', :id => @user.username

  rescue Exception => exception
    flash[:notice]= exception

  end


  #########################################
  # Pour AJAX,
  # @returns JSON
  #########################################
  def verify_username
    user = User.find_by_username(params[:username])
    valid_user = (user) ? true : false
    render :json => valid_user
  end

  #########################################
  # Upgrade user to editor
  # Admin function only
  #########################################
  def upgrade
    if user_signed_in? && self.current_user.admin_flag == 1
      user = User.find(params[:id])
      user.upgrade(params[:editor_flag])
      redirect_to(:controller => '/members', :action => 'profile', :id=>params[:id])
    end
  end


  #########################################
  # User Search
  #########################################
  def search
    @search_term = "%#{params[:query].downcase}%"
    @users = User.search_users(@search_term)
    render :json => @users
  end

  # utility
  def session_dump
    render :json => session
  end




end