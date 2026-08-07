class Web::BuildingsController < Web::ApplicationController
  include SecureUpload

  before_action :require_agent, except: [:index, :show]
  before_action :require_agent_or_owner, only: [:show]

  def index
    @buildings = if login_role == 'agence'
                   current_user.agency.buildings.includes(:owner, :apartments)
                 elsif login_role == 'tenant'
                   Building.where(id: current_user.building_id)
                  elsif login_role == 'owner'
                    current_owner ? current_owner.buildings.includes(:apartments) : Building.none
                 else
                   Building.all
                 end
  end

  def show
    @building = if login_role == 'agence'
                  current_user.agency.buildings.find(params[:id])
                elsif login_role == 'owner'
                  current_owner ? current_owner.buildings.find(params[:id]) : (raise ActiveRecord::RecordNotFound)
                else
                  raise ActiveRecord::RecordNotFound
                end
    @apartments = @building.apartments.includes(:tenant)
  end

  def new
    @building = Building.new
    @owners = Owner.order(:first_name)
  end

  def create
    @building = current_user.agency.buildings.new(building_params)

    begin
      handle_photo_upload if params[:building][:photo].present?
    rescue SecureUpload::UploadError => e
      @building.errors.add(:photo, e.message)
    end

    if @building.save
      redirect_to buildings_path, notice: 'Immeuble créé'
    else
      @owners = Owner.order(:first_name)
      flash.now[:alert] = @building.errors.full_messages.join(', ')
      render :new
    end
  end

  def edit
    @building = current_user.agency.buildings.find(params[:id])
    @owners = Owner.order(:first_name)
  end

  def update
    @building = current_user.agency.buildings.find(params[:id])

    begin
      handle_photo_upload if params[:building][:photo].present?
    rescue SecureUpload::UploadError => e
      @building.errors.add(:photo, e.message)
    end

    if @building.update(building_params)
      redirect_to @building, notice: 'Immeuble mis à jour'
    else
      @owners = Owner.order(:first_name)
      flash.now[:alert] = @building.errors.full_messages.join(', ')
      render :edit
    end
  end

  private

  def handle_photo_upload
    uploaded = params[:building][:photo]
    ext = validate_upload!(uploaded)
    filename = "building_#{@building.id || Time.now.to_i}_#{Time.now.to_i}.#{ext}"
    path = Rails.root.join('public', 'uploads', filename)
    File.open(path, 'wb') { |f| f.write(uploaded.read) }
    @building.photo = "/uploads/#{filename}"
  end

  def building_params
    params.require(:building).permit(:name, :address, :neighborhood, :commune, :latitude, :longitude, :owner_id, :photo)
  end
end
