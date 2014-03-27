#########################################
# SiteController
#
# @author: Andrew Lienhard
#########################################
class SiteController < ApplicationController
  include AuthenticatedSystem
  include TwitterModule

  before_filter :login_required, :only =>[:editor]

  @feedback_email = 'notification@jazzhouston.com'

  layout :detect_browser, :except=>[:radio_popup, :playlist, :twitter]

  def twitter
    @tweets = search('JazzHouston', 10)
  end

  def feedback
    @page_title = 'Feedback'
    if request.post?
      # check image
      challenge = session['uc']
      session['uc'] = nil
      test = challenge.checkResponse(params[:imageChallenge])
      if !test
        flash[:notice] = 'Invalid Image challenge response. Try again'
        return
      end

      name = params[:name]
      email = params[:email]

      if email
        # def feedback(to, name, email, subject, message, sent_at = Time.now)
        Notifier.feedback('notification@jazzhouston.com', name, email, 'Feedback from Jazzhouston', params[:message]).deliver
        flash[:notice] = 'Your feedback was sent. Thank you.'
      else
        flash[:notice] = 'Please include an email address'
      end
    end

  end

  def errorpage
    @exception = params[:exception]
    if @exception
      if @exception == '404'
        @error404=true
      elsif @exception == '500'
        @error500=true
      end
    end
  end

  def togglemobile
    cookies.delete :prefer_full_site
    cookies[:prefer_mobile] = 'true'
    redirect_to request.protocol + request.host_with_port + '/home'
  end

  def toggledesktop
    cookies[:prefer_full_site] = 'true'
    cookies.delete :prefer_mobile
    redirect_to request.protocol + request.host_with_port + '/home'
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
    # production
    store_path = '/home/jazzhouston/rails/jazzhouston/public/images'
    # dev
    #storePath = '/Users/andrew/Development/www/jazzhouston/public/images'
    filename = store_path + '/camouflage.png'

    challenge = UserChallenge::SumImageChallenger.new
    session['uc'] = challenge
    send_data challenge.render(filename), :filename => 'confirm.png',
              :type => 'image/png', :disposition => 'inline'
  end

  def redirect_page
    redirect_to params[:url].to_s
    headers['Status'] = '301 Moved Permanently'
  end

end
