require 'net/http'

class HackvertisementsController < ApplicationController
  # requires all routes of hackvertisement to be logged in to an account
  before_action :check_logged_in

  # sets the context for paths related to a specific hackvertisement
  before_action :set_hackvertisement, only: %i[ edit update destroy ]

  # check for /edit, /update and /destroy that the user accesing is the owner of the hackvertisement
  before_action :check_user, only: %i[ edit update destroy]
  
  def new
    @hackvertisement = Hackvertisement.new
  end

  def edit
  end

  # endpoint where new hackvertisement forms are sent.
  # handles verifying user data, uploading the image to the CDN,
  # and creating a database entry.
  def create
    data = params.expect(hackvertisement: [ :data, :link ])
    
    if data["data"] == nil
      redirect_to new_hackvertisement_path, notice: "Missing image"
      return
    end

    link = data["link"]
    if is_invalid_url(link)
      redirect_to new_hackvertisement_path, notice: "Missing or bad link."
      return
    end

    response = upload_image(data["data"])
    if response["error"] != nil
      redirect_to new_hackvertisement_path, notice: "Error uploading image to CDN: " + response["error"]
      return
    end

    @hackvertisement = Hackvertisement.new({"data": response["url"], "link":link, "user_id":session[:user_id]["uid"]})

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

  # endpoint where edit hackvertisement forms are sent.
  # handles verifying user data, uploading a new image to CDN if a new one was specified
  # and updating the database entry.
  def update
    form_params = params["hackvertisement"]
    new_image = form_params["data"]

    # by default, use previous values.
    image_url = @hackvertisement["data"]
    link = @hackvertisement["link"]

    if new_image != nil
      # new image was specified, upload to CDN and update url
      response = upload_image(new_image)
      
      if response["error"] != nil
        redirect_to new_hackvertisement_path, notice: "Error uploading image to CDN: " + response["error"]
        return
      end
      image_url = response["url"]
    end
    if form_params["link"] != nil and not is_invalid_url(form_params["link"])
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

  # destroys a specific hackvertisement
  def destroy
    @hackvertisement.destroy!

    respond_to do |format|
      format.html { redirect_to dashboard_path, notice: "Hackvertisement was successfully destroyed!", status: :see_other }
      format.json { head :no_content }
    end
  end

  
  # todo: maybe make /show and /index accessible for admin users?
  # could be a useful tool to have
  def show
    # disable standard route for viewing hackvertisement
    redirect_to root_path
  end

  def index
    # disable standard route for hackvertisements index
    redirect_to root_path
  end

  def wipe
    # todo: remove this
    # (like seriously it would be really bad if it made it to production)
    Hackvertisement.delete_all
    redirect_to root_path
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

    def check_user
      if @hackvertisement["user_id"] != session[:user_id]["uid"]
        redirect_to dashboard_path, notice: "This hackvertisement isn't yours, buckaroo.", status: :see_other
      end
    end

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
