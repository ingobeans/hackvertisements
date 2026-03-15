require 'net/http'
require "fastimage"

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
      redirect_to new_hackvertisement_path, notice: "error: Missing image"
      return
    end

    link = data["link"]
    if is_invalid_url(link)
      redirect_to new_hackvertisement_path, notice: "error: Missing or bad link."
      return
    end

    is_image_valid = isImageValid(data["data"])
    if is_image_valid[:error] != nil
      redirect_to new_hackvertisement_path, notice: "error: "+ is_image_valid[:error]
      return
    end
    file_data = is_image_valid[:data]

    response = upload_image(file_data,data["data"].original_filename)
    if response["error"] != nil
      redirect_to new_hackvertisement_path, notice: "error: Error uploading image to CDN: " + response["error"]
      return
    end

    @hackvertisement = Hackvertisement.new({"data": response["url"], "link":link, "user_id":session[:user_id]["uid"]})

    if @hackvertisement.save
      redirect_to dashboard_path, notice: "Hackvertisement was successfully created!"
    else
      render new_hackvertisement_path, status: :unprocessable_entity
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
      # new image was specified, check that it is valid, upload to CDN and update url
      
      is_image_valid = isImageValid(new_image)
      if is_image_valid[:error] != nil
        redirect_to :edit, notice: "error: "+is_image_valid[:error]
        return
      end

      response = upload_image(is_image_valid[:data],new_image.original_filename)
      
      if response["error"] != nil
        redirect_to :edit, notice: "error: Error uploading image to CDN: " + response["error"]
        return
      end
      image_url = response["url"]
    end
    if form_params["link"] != nil and not is_invalid_url(form_params["link"])
      link = form_params["link"]
    end

    update_data = {"data": image_url, "link": link}
    if @hackvertisement.update(update_data)
      redirect_to dashboard_path, notice: "Hackvertisement was successfully updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # destroys a specific hackvertisement
  def destroy
    @hackvertisement.destroy!
    
    redirect_to dashboard_path, notice: "Hackvertisement was successfully destroyed!"
  end

  
  # todo: maybe make /show and /index accessible for admin users?
  # could be a useful tool to have
  def show
    # disable standard route for viewing hackvertisement,
    # unless user is admin

    if session[:user_id]["id"] != 1
      redirect_to root_path
    end
    @hackvertisement = set_hackvertisement
  end

  def index
    # disable standard route for hackvertisements index,
    # unless user is admin

    if session[:user_id]["id"] != 1
      redirect_to root_path
    end
  end

  def wipe
    # todo: remove this
    # (like seriously it would be really bad if it made it to production)
    Hackvertisement.delete_all
    redirect_to root_path
  end

  private
    # checks that an uploaded file is an image,
    # that it is of the resolution 722x84,
    # and that it is not animated.
    # returns json response.
    # also returns the file data in the 'data' key if it is read. (since file reads exhaust the file object)
    def isImageValid(file)
      allowed_types = ["jpeg","jpg","png"]

      type = FastImage.type(file)
      if type == nil
        return {"error":"File is not recognized as an image"}
      end
      valid_type = allowed_types.include? type.to_s
      if not valid_type
        return {"error":"Image type is not allowed. Allowed types are "+allowed_types.join(", ")}
      end
      size = FastImage.size(file)
      if size != [722,84]
        return {"error":"Image must be of the size 722x84"}
      end
      file_data = file.read
      if type.to_s == "png" and isPngAnimated(file_data)
        return {"error":"Animated PNGs are not allowed","data":file_data}
      end

      # success state!
      # the file data is returned, as the file data
      # can only be read once from a single file object,
      # and since it is used here, the file data also needs
      # to be returned so that it can be used
      {"data":file_data}
    end

    # reads png file data to determine if it is animated
    def isPngAnimated(data)
      idat_pos = data.index('IDAT')
      idat_pos != nil and data[0..idat_pos].index('acTL') != nil 
    end

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
      is_root = session[:user_id]["id"] == 1
      if not is_root and @hackvertisement["user_id"] != session[:user_id]["uid"]
        redirect_to dashboard_path, notice: "error: This hackvertisement isn't yours, buckaroo."
      end
    end

    def check_logged_in
      if session[:user_id] == nil
        redirect_to root_path
      end
    end

    def upload_image(data,filename)
      puts "uploading " + filename
      ext = filename.split(".")[-1]
      cdn_url = ENV["CDN_BASE_URL"] + "/api/v4/upload"
      puts "sending to " + cdn_url
      uri = URI(cdn_url)
      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = 'Bearer ' + ENV["CDN_KEY"]
      form_data = [['file', data, {filename: "hackvertisement."+ext}]]
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
