#encoding: utf-8
module JazzHoustonConstants

  ## User Whitelist
  USER_WHITELIST_ATTRS = [:username, :email, :password, :password_confirmation,  :first_name, :last_name, :about_me,
                     :occupation, :location, :url, :favorite_music, :favorite_films, :home_phone,
                     :cell_phone, :remember_token, :remember_token_expires_at, :image,
                     :image_url, :hide_email, :twitter_name, :remember_me,
                     :pictures_attributes => ['id', 'description', 'picture', '_destroy']]






end