class HomeController < ApplicationController
  def index
    @logged_in = session[:user_id] != nil 
    render "index"
  end
  def dashboard
    if session[:user_id] == nil
      redirect_to root_path
    else
      @hackvertisements = Hackvertisement.where(user_id:session[:user_id]["uid"]).reverse
      render "dashboard"
    end
  end

  # serves the random hackvertisement for embeds!
  def serve
    # pick random entry.
    # i got this code from stack overflow dw i dont know how this works either :3
    @entry = Hackvertisement.order("RANDOM()").first

    render "embed", :layout => false
  end
end
