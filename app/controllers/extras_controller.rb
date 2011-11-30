################################
# Extras class
# no DB references
#
# Andrew, 10/2008
################################

class ExtrasController < ApplicationController

    ################################
    # ACTIONS
    ################################

    def index
		#@albums=Album.find(:all, :order=>"release_date desc", :limit=>10)
    end

    def education
		
    end
end