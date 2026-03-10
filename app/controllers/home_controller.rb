class HomeController < ApplicationController
  def index
    if session[:user_id] == nil 
      render "guest"
    else
      render "index"
    end
  end
end
