#########################################
# SiteController
#
# @author: Andrew Lienhard
#########################################
class SiteController < ApplicationController
  include TwitterModule

  #before_filter :login_required, :only =>[:editor]

  layout :detect_browser, :except=>[:radio_popup, :playlist, :twitter]

  # For Feedback Page
  # TODO refactor routes
  def feedback
    params[:title] = 'JazzHouston Feedback'

    # TODO REST: change routes to separate method!
    if request.post?
      serviceable = SiteServiceable.new(params, session)
      # check challenge image
      unless serviceable.challenge
        flash[:notice] = 'Invalid Image challenge response. Try again'
        return
      end

      if params[:email]
        # send email
        serviceable.send_email
        flash[:notice] = 'Your feedback was sent. Thank you.'
      else
        flash[:notice] = 'Please include an email address'
      end
    end

    @page_title = 'Feedback'

  end

  # Toggle between mobile and desktop site
  def toggle
    if params[:t] == 'mobile'
      cookies.delete :prefer_full_site
      cookies[:prefer_mobile] = 'true'
    else
      cookies[:prefer_full_site] = 'true'
      cookies.delete :prefer_mobile
    end
    redirect_to request.protocol + request.host_with_port + '/home'
    end


    # for Twitter Feed Page
    def twitter
      @tweets = search('JazzHouston', 10)
    end

    def contact
      redirect_to :action=>'feedback'
    end

    def editor
      @page_title='Site Editor Notes'
    end

    def faq
      @page_title='FAQ'
    end

    def about
      @page_title='About'
    end

    def history
      @page_title='History'
    end

    def privacy
      @page_title='Privacy'
    end

    def legal
      @page_title='Legal'
    end

    # the pop-up window
    def radio_popup

    end

    def radio
      @page_title='Radio'
    end

    def etc
      @page_title='Etc'
      @users = User.find(:all, :conditions=>'status_id=0', :order=>'user_id desc', :limit=>10)
    end

    def institute
      @page_title='Houston Jazz Institute'
    end

    # track rotator
    # returns xspf (ie, xml) playlist
    def playlist
      headers['Content-Type'] = 'text/xml; charset=utf-8'
    end

    # challenge image: TODO put this in a shared lib
    def challenge_image
      serviceable = SiteServiceable.new(params, session)

      send_data serviceable.challenge_image,
                :filename => 'confirm.png',
                :type => 'image/png',
                :disposition => 'inline'
    end

    def redirect_page
      redirect_to params[:url].to_s
      headers['Status'] = '301 Moved Permanently'
    end

  end
