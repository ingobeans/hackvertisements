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
    puts target_uid
    existing_user = User.where(uid:target_uid).first()
    if existing_user == nil
      puts "naurr!!!! dev login failed cause that user id doesnt belong to a user???"
      redirect_to root_path
      return
    end
    puts "you're logged in now!! you go girl!"
    session[:user_id] = existing_user
    redirect_to dashboard_path
  end

  def wipe
    # todo: remove this
    User.delete_all
    redirect_to root_path
  end

  # callback endpoint for the hackclub authentication.
  # handles the returned code and exchanges it for a token,
  # checks if new user, if so also fetches slack information.
  # sets user session, and updates database entry.
  def create
    puts "hi, im gonna try to authenticate now :3"

    # exchange code for token
    uri = URI.parse('https://auth.hackclub.com/oauth/token')
    data = '{
      "client_id": "'+ ENV["CLIENT_ID"]+ '",
      "client_secret": "'+ ENV["CLIENT_SECRET"]+ '",
      "redirect_uri": "http://localhost:3000/auth/:provider/callback",
      "code": "' + params["code"] + '",
      "grant_type": "authorization_code"
    }'
    headers = {'content-type': 'application/json'}
    res = Net::HTTP.post(uri, data, headers)
    
    if res.body.include? "error"
      render json: {error: "Invalid authentication code", status: 400}.to_json 
    else
      # returned data from hackclub auth, containing user token
      data = JSON.parse(res.body)
      
      # get the user's slackID from the hackclub auth api
      uri = URI.parse("https://auth.hackclub.com/oauth/userinfo")
      headers = {'Authorization': 'Bearer ' + data["access_token"]}

      body = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        req = Net::HTTP::Get.new(uri)
        req['Authorization'] = 'Bearer ' + data["access_token"]
        response = http.request(req)
        response.body
      end
      
      user_data = JSON.parse(body)

      # try to find existing user
      existing_user = User.where(uid:user_data["slack_id"]).first()

      if existing_user == nil
        puts "NEW USER ALERT!!!"
        
        # get new user's slack username and profile picture using the cachet api
        uri = URI.parse("https://cachet.dunkirk.sh/users/"+user_data["slack_id"])
        hostname = uri.hostname
        req = Net::HTTP::Get.new(uri)
        res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
          http.request(req)
        end
        slack_data = JSON.parse(res.body)
        
        # construct the new user :3
        user = User.new({"uid":user_data["slack_id"], "token":data["access_token"], "name":slack_data["displayName"], "pfp":slack_data["imageUrl"], "posts":""})
        session[:user_id] = user
        user.save
      else
        puts "WELCOME back"
        # returning user, only update the token,
        # and log in the user session.

        existing_user["token"] = data["access_token"]
        
        session[:user_id] = existing_user
        existing_user.save
      end
      redirect_to dashboard_path
    end
  end
end