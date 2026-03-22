class ApiController < ApplicationController
    before_action :set_cors, except: :index
    before_action :get_entry, only: %i[ fetch fetch_url serve]
    before_action :save_lb, only: %i[ fetch fetch_url]

    def index
    end

    def fetch
        redirect_to @entry.data, allow_other_host: true
    end

    def fetch_url
        render plain: @entry.data
    end
    
    # serves the random hackvertisement for embeds!
    def serve
        # disable caching
        response.headers["Cache-Control"] = "no-cache, no-store"
        response.headers["Pragma"] = "no-cache"
        response.headers["Expires"] = "Mon, 01 Jan 1990 00:00:00 GMT"

        render "embed", :layout => false

        if params["anonymous"] != "1"
            save_lb(request.headers["referer"],false)
        end
    end

    private
        def is_invalid_url(link,allow_empty_scheme=false)
            begin
                if link == nil or link.blank?
                return true
                end
                uri = URI(link)
                empty_scheme = uri.scheme == nil && allow_empty_scheme == true
                (uri.scheme != "https") and (uri.scheme != "http") and not empty_scheme
            rescue
                true
            end
        end
        def save_lb(ref=params["referer"],allow_empty_scheme=true)
            if not is_invalid_url(ref,true)
                puts "saving api fetch to DB! referer is: " + ref.chomp
                response.headers["Leaderboard-Saved"] = "yes"
                entry = Lbentry.find_or_create_by(name: ref.delete_prefix("https://").delete_prefix("http://").delete_suffix("/"))
                entry.update({"hits":entry["hits"] == nil ? 1 : entry["hits"]+1})
                entry.save
            end
        end
        def get_entry
            @entry = Hackvertisement.order("RANDOM()").first
        end
        def set_cors
            headers['X-Frame-Options'] = 'ALLOWALL'
            headers['Access-Control-Allow-Origin'] = '*'
            headers['Access-Control-Allow-Methods'] = 'GET'
            headers['Access-Control-Request-Method'] = '*'
            headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
        end
end
