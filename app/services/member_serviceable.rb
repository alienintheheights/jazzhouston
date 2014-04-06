class MemberServiceable
  require 'RMagick'
  include UserChallenge

  def initialize(params, session)
    @params = params
    @session = session
  end


  #########################################
  # Load User
  #########################################
  def load
    # check by name, fallback to ID
    member = User.find_by_username(@params[:id].downcase) || User.find(@params[:id])
    raise NotConfirmed if member.status_id==1
    member
  end

  #########################################
  # Update
  #########################################
  def update
    user = User.find(@params[:id])

    # for remote updates by admins
    if user.password
      user = User.authenticate(user.username, user.password)
    end
    user.update_attributes(@params[:user])

    # get the instruments
    axes = map_instruments(user)
    if axes && axes.length > 0
      user.instruments = axes
      user.local_player_flag = 1
    else
      user.instruments = []
      user.local_player_flag = 0
    end
    user.save
    user
  end


  #########################################
  # Check whether user is active
  #########################################
  def is_active(user)
    user.status_id != 0
  end

  #########################################
  # Wrapper for password change function
  #########################################
  def change_password(username, old_pw, new_pwd)
    self.user.change_password(username, old_pw, new_pwd)
  end

  #########################################
  # Wrapper for user's method of the same
  #########################################
  def update_password(user, new_password)
    user.update_password(new_password)
  end

  #########################################
  # Set user to active
  #########################################
  def activate_user(user)
    user.status_id=0
    user.save
  end


  #########################################
  # Checks user input on challenge image
  #########################################
  def verify_image
    unless Rails.env.production?
        return true
    end
    # image challenge check
    challenge = @session['uc']
    @session['uc'] = nil
    verify_image = false
    if challenge && @params[:imageChallenge]
      verify_image = challenge.checkResponse(@params[:imageChallenge])
    end
    raise InvalidChallengeValue unless verify_image
  end


  private

  # scans instruments from params and updates user object
  def map_instruments(user)
    user.instruments = []
    # get the instruments
    user_instruments = @params[:instrument]
    if user_instruments
      for item in user_instruments
        user.instruments << Instrument.find(item[0])
      end
    end
    user.instruments
  end


end
