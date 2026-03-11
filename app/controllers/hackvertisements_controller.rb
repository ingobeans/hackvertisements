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
    @hackvertisement = Hackvertisement.new
  end

  # GET /hackvertisements/1/edit
  def edit
  end

  # POST /hackvertisements or /hackvertisements.json
  def create
    data = params.expect(hackvertisement: [ :data, :link ])
    puts data["data"].class
    puts "wa"

    @hackvertisement = Hackvertisement.new

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
