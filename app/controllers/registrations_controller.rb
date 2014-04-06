class RegistrationsController < Devise::RegistrationsController


  def after_sign_ups_path_for(resource)
    '/members'
  end



end
