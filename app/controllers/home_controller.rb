class HomeController < ApplicationController
  def index
    @logged_in = session[:user_id] != nil 
    render "index"
  end
  def dashboard
    if session[:user_id] == nil
      redirect_to root_path
    else
      @hackvertisements = Hackvertisement.where(user_id:session[:user_id]["uid"])
      render "dashboard"
    end
  end
end
