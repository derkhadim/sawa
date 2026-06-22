class Web::BuildingsController < Web::ApplicationController
  ALLOWED_EXTENSIONS = %w[jpg jpeg png gif webp].freeze

  before_action :require_agent, except: [:index, :show]
  before_action :require_agent_or_owner, only: [:show]

  def index
    @buildings = if login_role == 'agence'
                   current_user.agency.buildings.includes(:owner, :apartments)
                 elsif login_role == 'tenant'
                   Building.where(id: current_user.building_id)
                 elsif login_role == 'owner'
                   owner = Owner.find_by(email: current_user.email)
                   owner ? owner.buildings.includes(:apartments) : Building.none
                 else
                   Building.all
                 end
  end

  def show
    @building = if login_role == 'agence'
                  current_user.agency.buildings.find(params[:id])
                elsif login_role == 'owner'
                  owner = Owner.find_by(email: current_user.email)
                  owner ? owner.buildings.find(params[:id]) : (raise ActiveRecord::RecordNotFound)
                else
                  raise ActiveRecord::RecordNotFound
                end
    @apartments = @building.apartments.includes(:tenant)
  end

  def new
    @building = Building.new
    @owners = current_user.agency.owners
  end

  def create
    @building = current_user.agency.buildings.new(building_params)

    handle_photo_upload if params[:building][:photo].present?

    if @building.save
      redirect_to buildings_path, notice: 'Immeuble créé'
    else
      @owners = current_user.agency.owners
      flash.now[:alert] = @building.errors.full_messages.join(', ')
      render :new
    end
  end

  def edit
    @building = current_user.agency.buildings.find(params[:id])
    @owners = current_user.agency.owners
  end

  def update
    @building = current_user.agency.buildings.find(params[:id])

    handle_photo_upload if params[:building][:photo].present?

    if @building.update(building_params)
      redirect_to @building, notice: 'Immeuble mis à jour'
    else
      @owners = current_user.agency.owners
      flash.now[:alert] = @building.errors.full_messages.join(', ')
      render :edit
    end
  end

  private

  def handle_photo_upload
    uploaded = params[:building][:photo]
    ext = safe_extension(uploaded.original_filename)
    filename = "building_#{@building.id || Time.now.to_i}_#{Time.now.to_i}.#{ext}"
    path = Rails.root.join('public', 'uploads', filename)
    File.open(path, 'wb') { |f| f.write(uploaded.read) }
    @building.photo = "/uploads/#{filename}"
  end

  def safe_extension(filename)
    ext = filename.split('.').last&.downcase
    return 'jpg' unless ext && ALLOWED_EXTENSIONS.include?(ext)
    ext
  end

  def building_params
    params.require(:building).permit(:name, :address, :neighborhood, :commune, :latitude, :longitude, :owner_id, :photo)
  end
end
