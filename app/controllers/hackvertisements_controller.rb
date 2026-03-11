require 'net/http'

class HackvertisementsController < ApplicationController
  before_action :set_hackvertisement, only: %i[ show edit update destroy ]

  # GET /hackvertisements or /hackvertisements.json
  def index
    @hackvertisements = Hackvertisement.all
  end

  # GET /hackvertisements/1 or /hackvertisements/1.json
  def show
  end

  # GET /hackvertisements/new
  def new
    if session[:user_id] == nil
      redirect_to root_path
    end
    @hackvertisement = Hackvertisement.new
  end

  # GET /hackvertisements/1/edit
  def edit
  end

  # POST /hackvertisements or /hackvertisements.json
  def create
    if session[:user_id] == nil
      redirect_to root_path
    end
    data = params.expect(hackvertisement: [ :data, :link ])
    puts data["data"].class
    filename = data["data"].original_filename
    ext = filename.split(".")[-1]
    cdn_url = ENV["CDN_BASE_URL"] + "/api/v4/upload"
    puts "sending to " + cdn_url
    uri = URI(cdn_url)
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = 'Bearer ' + ENV["CDN_KEY"]
    form_data = [['file', data["data"].read, {filename: "hackvertisement."+ext}]]
    request.set_form(form_data, 'multipart/form-data')
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: !Rails.env.development?) do |http|
      http.request(request)
    end
    puts "yay!!!"
    response = JSON.parse(response.body)
    image_url = response["url"]

    @hackvertisement = Hackvertisement.new({"data": response["url"], "link":data["link"], "user_id":session[:user_id]["uid"]})
    if session[:user_id]["posts"] == "" 
      session[:user_id]["posts"] = @hackvertisement["id"]
    else
      session[:user_id]["posts"] = session[:user_id]["posts"] + "," + @hackvertisement["id"]
    end
    puts session[:user_id]["posts"] 

    respond_to do |format|
      if @hackvertisement.save
        format.html { redirect_to @hackvertisement, notice: "Hackvertisement was successfully created." }
        format.json { render :show, status: :created, location: @hackvertisement }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @hackvertisement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /hackvertisements/1 or /hackvertisements/1.json
  def update
    respond_to do |format|
      if @hackvertisement.update(hackvertisement_params)
        format.html { redirect_to @hackvertisement, notice: "Hackvertisement was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @hackvertisement }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @hackvertisement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /hackvertisements/1 or /hackvertisements/1.json
  def destroy
    @hackvertisement.destroy!

    respond_to do |format|
      format.html { redirect_to hackvertisements_path, notice: "Hackvertisement was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_hackvertisement
      @hackvertisement = Hackvertisement.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def hackvertisement_params
      params.expect(hackvertisement: [ :user_id, :date, :data, :link ])
    end
end
