class HomeController < ApplicationController
  def index
    if session[:user_id] == nil 
      render "guest"
    else
      @hackvertisements = Hackvertisement.where("user_id":session[:user_id]["uid"])
      render "index"
    end
  end
end
