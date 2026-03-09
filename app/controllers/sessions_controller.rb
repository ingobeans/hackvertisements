require 'net/http'

class SessionsController < ApplicationController
  def delete
    session[:user_id] = nil
    redirect_to root_path
  end
  def create
    puts "hi, im gonna try to authenticate now :3"
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
      data = JSON.parse(res.body)
      puts data["access_token"]
      uri = URI.parse("https://auth.hackclub.com/oauth/userinfo")
      headers = {'Authorization': 'Bearer ' + data["access_token"]}

      body = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        req = Net::HTTP::Get.new(uri)
        req['Authorization'] = 'Bearer ' + data["access_token"]
        response = http.request(req)
        response.body
      end
      
      puts body
      user_data = JSON.parse(body)
      existing_user = User.where(uid:user_data["slack_id"]).first()
      if existing_user == nil
        puts "NEW USER ALERT!!!"
        user = User.new({"uid":user_data["slack_id"], "token":data["access_token"], "name":user_data["nickname"]})
        session[:user_id] = user
        user.save
      else
        puts "WELCOME back"
        existing_user["token"] = data["access_token"]
        session[:user_id] = existing_user
        existing_user.save
      end
      redirect_to root_path
    end
  end
end