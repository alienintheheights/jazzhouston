class CustomFailure < Devise::FailureApp

  # Override
  def redirect_url
    root_path
  end

end