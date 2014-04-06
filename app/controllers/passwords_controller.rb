class PasswordsController < Devise::PasswordsController
  protected
  def after_sending_reset_password_instructions_path_for(resource_name)
    after_sign_in_path_for(resource)
  end

  def after_resetting_password_path_for(resource)
    after_sign_in_path_for(resource)
  end

end