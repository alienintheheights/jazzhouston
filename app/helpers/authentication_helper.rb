module AuthenticationHelper

  def is_logged_in?
    user_signed_in?
  end

  def is_editor?
    return unless user_signed_in?
    return if current_user.nil?
    current_user.editor_flag==1
  end


end