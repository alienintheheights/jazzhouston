
class EducationController < ApplicationController

  caches_page :index
  def index
    @page_title="Education"
  end
end
