################################
# Institute Page
#
# Andrew, 7/2009
################################

class InstitutesController < ApplicationController


    ################################
    # ACTIONS
    ################################

    # the index page
    def index
	redirect_to "http://www.jazzhouston.com/articles/words/jazzinstitute"
    end

end
