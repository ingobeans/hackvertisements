require 'net/http'

class SessionsController < ApplicationController
  # endpoint destroying a session, i.e. signing out
  def delete
    session[:user_id] = nil
    redirect_to root_path
  end

  # endpoint for dev login form submissions
  def dev
    if !Rails.env.development?
      redirect_to root_path
      return
    end

    target_uid = params["uid"]

    # find user with that id
    existing_user = User.where(uid:target_uid).first()
    if existing_user == nil
      redirect_to dashboard_path, notice: "error: naurr!!!! dev login failed cause that user id doesnt belong to a user???"
      return
    end
    
    session[:user_id] = existing_user
    redirect_to dashboard_path, notice: "you're logged in now!! you go girl!"
  end

  # callback endpoint for the hackclub authentication.
  # handles the returned code and exchanges it for a token,
  # checks if new user, if so also fetches slack information.
  # sets user session, and updates database entry.
  def create
    puts "hi, im gonna try to authenticate now :3"
    
    if params["code"] == nil or params["code"].blank?
      render json: {error: "Missing authentication code", status: 400}.to_json 
      return
    end

    # exchange code for token
    uri = URI.parse('https://auth.hackclub.com/oauth/token')
    data = '{
      "client_id": "'+ ENV["CLIENT_ID"]+ '",
      "client_secret": "'+ ENV["CLIENT_SECRET"]+ '",
      "redirect_uri": "' + url_for(only_path: false) + '",
      "code": "' + params["code"] + '",
      "grant_type": "authorization_code"
    }'
    headers = {'content-type': 'application/json'}
    res = Net::HTTP.post(uri, data, headers)

    token = ""

    # whether the authentication was unsuccesful
    error = (not (res.kind_of? Net::HTTPSuccess)) or res.body.include? "error"

    if not error
      data = JSON.parse(res.body)

      if data == nil or data["access_token"] == nil
        # mark authentication as unsuccesful
        error = true
      else
        token = data["access_token"]
      end
    end

    if error
      render json: {error: "Invalid authentication code or authentication server was unreachable (its probably the first option ngl)", status: 400}.to_json 
    else
      # get the user's slackID from the hackclub auth api
      uri = URI.parse("https://auth.hackclub.com/oauth/userinfo")
      headers = {'Authorization': 'Bearer ' + token}

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        req = Net::HTTP::Get.new(uri)
        req['Authorization'] = 'Bearer ' + token
        response = http.request(req)
        response
      end
      
      if not (response.kind_of? Net::HTTPSuccess)
        render json: {error: "Problem fetching user info", status: 500}.to_json 
        return
      end

      body = response.body
      user_data = JSON.parse(body)

      if user_data == nil or user_data["slack_id"] == nil
        render json: {error: "Bad user info", status: 500}.to_json 
        return
      end

      slack_id = user_data["slack_id"]

      # try to find existing user
      existing_user = User.where(uid:slack_id).first()

      if existing_user == nil
        puts "NEW USER ALERT!!!"
        
        # get new user's slack username and profile picture using the cachet api
        uri = URI.parse("https://cachet.dunkirk.sh/users/"+slack_id)
        hostname = uri.hostname
        req = Net::HTTP::Get.new(uri)
        res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
          http.request(req)
        end
        slack_data = JSON.parse(res.body)
        
        # construct the new user :3
        user = User.new({"uid":slack_id, "token":token, "name":slack_data["displayName"], "pfp":slack_data["imageUrl"]})
        session[:user_id] = user
        user.save
      else
        puts "WELCOME back"
        # returning user, only update the token,
        # and log in the user session.

        existing_user["token"] = token

        session[:user_id] = existing_user
        existing_user.save
      end
      redirect_to dashboard_path
    end
  end
end