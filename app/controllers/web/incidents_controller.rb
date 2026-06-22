class Web::IncidentsController < Web::ApplicationController
  def index
    @apartment = Apartment.find(params[:apartment_id])
    @incidents = @apartment.incidents.order(created_at: :desc).includes(:provider)
  end

  def tenant_index
    require_role(:tenant)
    @apartment = current_user.apartments_as_tenant.first
    unless @apartment
      redirect_to dashboard_tenant_path, alert: 'Aucun appartement assigné'
      return
    end
    @incidents = @apartment.incidents.order(created_at: :desc).includes(:tenant, :provider)
  end

  def agent_index
    require_role(:agence)
    agency = current_user.agency
    building_ids = agency.buildings.pluck(:id)
    apartment_ids = Apartment.where(building_id: building_ids).pluck(:id)
    @incidents = Incident.where(apartment_id: apartment_ids).order(created_at: :desc).includes(:tenant, :apartment, :provider)
  end

  def show
    @incident = Incident.find(params[:id])
    if current_user.agence?
      @providers = current_user.agency.providers.order(:last_name)
    end
  end

  def new
    @apartment = Apartment.find(params[:apartment_id])
    @incident = @apartment.incidents.new
  end

  def create
    @apartment = Apartment.find(params[:apartment_id])

    unless current_user.tenant? && current_user.id == @apartment.tenant_id
      redirect_to @apartment, alert: 'Accès refusé'
      return
    end

    @incident = @apartment.incidents.new(incident_params.merge(tenant: current_user))

    if @incident.save
      redirect_to dashpath, notice: 'Signalement envoyé'
    else
      flash.now[:alert] = @incident.errors.full_messages.join(', ')
      render :new
    end
  end

  def update
    @incident = Incident.find(params[:id])

    unless current_user.agence? || (current_user.tenant? && current_user.id == @incident.tenant_id)
      redirect_to root_path, alert: 'Accès refusé'
      return
    end

    if @incident.update(update_params)
      redirect_to @incident, notice: 'Signalement mis à jour'
    else
      redirect_back fallback_location: dashboard_path, alert: 'Erreur'
    end
  end

  private

  def incident_params
    params.require(:incident).permit(:title, :description)
  end

  def update_params
    if current_user.agence?
      params.permit(:status, :provider_id)
    else
      params.permit(:status)
    end
  end

  def dashpath
    current_user.tenant? ? dashboard_tenant_path : dashboard_path
  end
end
