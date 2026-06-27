class Web::ApartmentsController < Web::ApplicationController
  ALLOWED_EXTENSIONS = %w[jpg jpeg png gif webp].freeze

  before_action :require_agent, except: [:show]

  def index
    @building = find_building_in_scope
    @apartments = @building.apartments.includes(:tenant)
  end

  def show
    @apartment = find_apartment_in_scope
    @payments = @apartment.payments.order(year: :desc, month: :desc)
    @incidents = @apartment.incidents.order(created_at: :desc)
  end

  def new
    @building = Building.find(params[:building_id])
    @apartment = @building.apartments.new
  end

  def create
    @building = current_user.agency.buildings.find(params[:building_id])
    @apartment = @building.apartments.new(apartment_params)

    handle_photos_upload if params[:apartment][:photos].present?

    if @apartment.save
      redirect_to @building, notice: 'Appartement créé'
    else
      flash.now[:alert] = @apartment.errors.full_messages.join(', ')
      render :new
    end
  end

  def edit
    @apartment = Apartment.joins(:building).where(buildings: { agency_id: current_user.agency_id }).find(params[:id])
  end

  def update
    @apartment = Apartment.joins(:building).where(buildings: { agency_id: current_user.agency_id }).find(params[:id])

    handle_photos_upload if params[:apartment][:photos].present?

    if @apartment.update(apartment_params)
      redirect_to @apartment, notice: 'Appartement mis à jour'
    else
      flash.now[:alert] = @apartment.errors.full_messages.join(', ')
      render :edit
    end
  end

  def assign_tenant
    @apartment = Apartment.joins(:building).where(buildings: { agency_id: current_user.agency_id }).find(params[:id])

    if @apartment.occupied?
      redirect_to @apartment, alert: 'Appartement déjà occupé'
      return
    end

    tenant = User.find_by(phone: params[:phone], role: 'tenant')

    unless tenant
      tenant = User.new(
        phone: params[:phone],
        role: 'tenant',
        first_name: params[:first_name].presence || 'Locataire',
        last_name: params[:last_name].presence || params[:phone],
        email: params[:email].presence || "#{params[:phone]}@temp.loca",
        password: SecureRandom.hex(8),
        building_id: @apartment.building_id
      )
      tenant.save!
    end

    @apartment.update!(tenant: tenant, status: 'occupied')
    tenant.update!(building_id: @apartment.building_id)

    now = Time.current
    @apartment.payments.create!(
      tenant: tenant,
      amount: @apartment.rent_amount,
      due_date: Payment.default_due_date(now.year, now.month),
      month: now.month,
      year: now.year,
      status: 'pending'
    )

    redirect_to @apartment, notice: 'Locataire assigné'
  rescue ActiveRecord::RecordInvalid => e
    redirect_to @apartment, alert: "Erreur: #{e.message}"
  end

  def unassign_tenant
    @apartment = Apartment.joins(:building).where(buildings: { agency_id: current_user.agency_id }).find(params[:id])

    unless @apartment.occupied?
      redirect_to @apartment, alert: 'Appartement déjà libre'
      return
    end

    tenant = @apartment.tenant
    @apartment.update!(tenant: nil, status: 'free')
    tenant.update!(building_id: nil)

    redirect_to @apartment, notice: "Locataire #{tenant.full_name} désassigné"
  end

  private

  def require_agent
    require_role(:agence)
  end

  def handle_photos_upload
    uploaded_files = Array(params[:apartment][:photos])
    paths = uploaded_files.first(4).map do |file|
      next unless file.respond_to?(:original_filename)
      ext = safe_extension(file.original_filename)
      filename = "apt_#{@apartment.id || Time.now.to_i}_#{SecureRandom.hex(4)}.#{ext}"
      path = Rails.root.join('public', 'uploads', filename)
      File.open(path, 'wb') { |f| f.write(file.read) }
      "/uploads/#{filename}"
    end.compact

    @apartment.photos = paths.to_json
  end

  def safe_extension(filename)
    ext = filename.split('.').last&.downcase
    return 'jpg' unless ext && ALLOWED_EXTENSIONS.include?(ext)
    ext
  end

  def apartment_params
    params.require(:apartment).permit(:number, :floor, :rent_amount, :status)
  end
end
