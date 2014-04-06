class SiteServiceable
  require 'RMagick'
  include UserChallenge

  def initialize(params, session)
    @params = params
    @session = session
  end


  # send email
  def send_email
    Notifier.feedback('andrew@fauxmat.com',
                      @params[:name],
                      @params[:email],
                      @params[:title],
                      @params[:message]).deliver
  end


  # check rendered challenge image
  def challenge
    challenge = @session['uc']
    @session['uc'] = nil
    challenge.checkResponse(@params[:imageChallenge])
  end



  # challenge image renderer
  def challenge_image
    filename = Rails.root.join('public','images', 'camouflage.png')

    challenge = UserChallenge::SumImageChallenger.new
    @session['uc'] = challenge
    challenge.render(filename)
  end

end