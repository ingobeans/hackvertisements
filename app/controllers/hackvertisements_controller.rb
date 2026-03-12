require 'net/http'

class HackvertisementsController < ApplicationController
  before_action :check_logged_in
  before_action :set_hackvertisement, only: %i[ show edit update destroy ]

  def wipe
    Hackvertisement.delete_all
    redirect_to root_path
  end

  # GET /hackvertisements or /hackvertisements.json
  def index
    @hackvertisements = Hackvertisement.all
  end

  # GET /hackvertisements/1 or /hackvertisements/1.json
  def show
  end

  # GET /hackvertisements/new
  def new
    @hackvertisement = Hackvertisement.new
  end

  # GET /hackvertisements/1/edit
  def edit
    if @hackvertisement["user_id"] != session[:user_id]["uid"]
      redirect_to dashboard_path, notice: "This hackvertisement isn't yours, buckaroo.", status: :see_other
    end
  end

  # POST /hackvertisements or /hackvertisements.json
  def create
    data = params.expect(hackvertisement: [ :data, :link ])
    puts data["data"].class
    response = upload_image(data["data"])

    @hackvertisement = Hackvertisement.new({"data": response["url"], "link":data["link"], "user_id":session[:user_id]["uid"]})
    if session[:user_id]["posts"] == "" or session[:user_id]["posts"] == nil
      session[:user_id]["posts"] = @hackvertisement["id"]
    else
      session[:user_id]["posts"] = session[:user_id]["posts"] + "," + @hackvertisement["id"]
    end
    puts session[:user_id]["posts"] 

    respond_to do |format|
      if @hackvertisement.save
        format.html { redirect_to dashboard_path, notice: "Hackvertisement was successfully created!" }
        format.json { render :show, status: :created, location: @hackvertisement }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @hackvertisement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /hackvertisements/1 or /hackvertisements/1.json
  def update
    if @hackvertisement["user_id"] != session[:user_id]["uid"]
      redirect_to dashboard_path, notice: "This hackvertisement isn't yours, buckaroo.", status: :see_other
    end
    form_params = params["hackvertisement"]
    new_image = form_params["data"]
    image_url = @hackvertisement["data"]
    link = @hackvertisement["link"]
    if new_image != nil
      puts "new image!"
      
      response = upload_image(new_image)
      image_url = response["url"]
    end
    if form_params["link"] != nil
      link = form_params["link"]
    end
    update_data = {"data": image_url, "link": link}
    respond_to do |format|
      if @hackvertisement.update(update_data)
        format.html { redirect_to dashboard_path, notice: "Hackvertisement was successfully updated!", status: :see_other }
        format.json { render :show, status: :ok, location: @hackvertisement }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @hackvertisement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /hackvertisements/1 or /hackvertisements/1.json
  def destroy
    if @hackvertisement["user_id"] != session[:user_id]["uid"]
      redirect_to dashboard_path, notice: "This hackvertisement isn't yours, buckaroo.", status: :see_other
    end
    @hackvertisement.destroy!

    respond_to do |format|
      format.html { redirect_to dashboard_path, notice: "Hackvertisement was successfully destroyed!", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    def check_logged_in
      if session[:user_id] == nil
        redirect_to root_path
      end
    end

    def upload_image(data)
      filename = data.original_filename
      puts "uploading " + filename
      ext = filename.split(".")[-1]
      cdn_url = ENV["CDN_BASE_URL"] + "/api/v4/upload"
      puts "sending to " + cdn_url
      uri = URI(cdn_url)
      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = 'Bearer ' + ENV["CDN_KEY"]
      form_data = [['file', data.read, {filename: "hackvertisement."+ext}]]
      request.set_form(form_data, 'multipart/form-data')
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: !Rails.env.development?) do |http|
        http.request(request)
      end
      puts "yay!!!"
      JSON.parse(response.body)
    end

    def set_hackvertisement
      @hackvertisement = Hackvertisement.find(params.expect(:id))
    end
end
