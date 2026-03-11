class HomeController < ApplicationController
  def index
    @logged_in = session[:user_id] != nil 
    render "index"
  end
end
