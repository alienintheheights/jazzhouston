#####################
# Auth helpers for JH
#
# March 2014 refactor
#
#####################
module JazzhoustonAuth

  # Error Classes
  class InvalidChallengeValue < StandardError
  end

  class UnauthorizedEditor < StandardError
  end

  class RequiresLogin < StandardError
  end

  # Module functions
  def self.included(base)

  end

  # Checks if user is an editor; throws exception if not
  def is_editor?
    if user_signed_in?
        raise JazzhoustonAuth::UnauthorizedEditor unless current_user.editor_flag==1
      else
        # or you can use the authenticate_user! devise provides to only allow signed_in users
        raise JazzhoustonAuth::RequiresLogin
      end
  end

  # forum check
  def is_forum_member?
      user_signed_in? # TODO add ban check
  end


end