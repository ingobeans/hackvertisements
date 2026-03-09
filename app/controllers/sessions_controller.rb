require 'net/http'

class SessionsController < ApplicationController
  def new
    render :new
  end

  def create

    user_info = request.env['omniauth.auth']
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

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        req = Net::HTTP::Get.new(uri)
        req['Authorization'] = 'Bearer ' + data["access_token"]
        response = http.request(req)
        puts response.body
      end

      @user = User.new
      
    end
  end
end