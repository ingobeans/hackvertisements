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
    # allow CORS
    headers['X-Frame-Options'] = 'ALLOWALL'
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'

    # disable caching
    response.headers["Cache-Control"] = "no-cache, no-store"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Mon, 01 Jan 1990 00:00:00 GMT"

    # pick random entry.
    # i got this code from stack overflow dw i dont know how this works either :3
    @entry = Hackvertisement.order("RANDOM()").first

    render "embed", :layout => false

    puts "referer:"
    puts request.headers["referer"]
    save_to_leaderboard = params["anonymous"] != 1 and not is_invalid_url(request.headers["referer"])
    puts save_to_leaderboard
    puts "^save?"
    if save_to_leaderboard
      entry = Lbentry.find_or_create_by(name: request.headers["referer"])
      entry.update({"hits":entry["hits"] == nil ? 1 : entry["hits"]+1})
      entry.save
    end
  end

  private
    def is_invalid_url(link)
      begin
        if link == nil or link.blank?
          return true
        end
        uri = URI(link)
        (uri.scheme != "https") and (uri.scheme != "http")
      rescue
        true
      end
    end
end
