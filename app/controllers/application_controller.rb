class ApplicationController < ActionController::API
  before_action :authenticate_request

  private

  def authenticate_request
    header = request.headers['Authorization']
    token = header&.split(' ')&.last
    decoded = JwtService.decode(token)

    if decoded
      @current_user = User.find_by(id: decoded[:user_id])
    end

    render json: { error: 'Non autorisé' }, status: :unauthorized unless @current_user
  end

  def current_user
    @current_user
  end

  def current_owner
    @current_owner ||= current_user&.owner
  end

  def require_role(role)
    unless current_user&.role == role.to_s
      render json: { error: 'Accès refusé' }, status: :forbidden
    end
  end

  def find_in_agency(scope)
    if current_user.agence?
      scope.joins(apartment: { building: :agency })
           .where(agencies: { id: current_user.agency_id })
           .find(params[:id])
    elsif current_user.owner?
      building_ids = current_owner&.buildings&.pluck(:id) || []
      scope.joins(:apartment).where(apartments: { building_id: building_ids }).find(params[:id])
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def find_building_resource(scope)
    if current_user.agence?
      building_ids = current_user.agency.buildings.pluck(:id)
      scope.where(building_id: building_ids).find(params[:id])
    elsif current_user.owner?
      building_ids = current_owner&.buildings&.pluck(:id) || []
      scope.where(building_id: building_ids).find(params[:id])
    elsif current_user.tenant?
      building_ids = current_user.tenant_buildings.pluck(:id)
      scope.where(building_id: building_ids).find(params[:id])
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def find_apartment_in_scope
    if current_user.agence?
      Apartment.joins(:building).where(buildings: { agency_id: current_user.agency_id }).find(params[:apartment_id] || params[:id])
    elsif current_user.owner?
      Apartment.where(building_id: current_owner&.buildings&.pluck(:id) || []).find(params[:apartment_id] || params[:id])
    elsif current_user.tenant?
      current_user.apartments_as_tenant.find(params[:apartment_id] || params[:id])
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def find_building_in_scope
    if current_user.agence?
      current_user.agency.buildings.find(params[:building_id] || params[:id])
    elsif current_user.owner?
      Building.where(id: current_owner&.buildings&.pluck(:id) || []).find(params[:building_id] || params[:id])
    elsif current_user.tenant?
      current_user.tenant_buildings.find(params[:building_id] || params[:id])
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def find_publication_in_scope
    if current_user.agence?
      building_ids = current_user.agency.buildings.pluck(:id)
      Publication.where(building_id: building_ids).find(params[:id])
    elsif current_user.tenant?
      building_ids = current_user.tenant_buildings.pluck(:id)
      Publication.where(building_id: building_ids).find(params[:id])
    elsif current_user.owner?
      building_ids = current_owner&.buildings&.pluck(:id) || []
      Publication.where(building_id: building_ids).find(params[:id])
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
