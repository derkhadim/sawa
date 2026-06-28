class Web::ApplicationController < ActionController::Base
  layout 'application'
  before_action :require_login

  helper_method :current_user, :logged_in?, :login_role, :current_owner

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def current_owner
    @current_owner ||= current_user&.owner
  end

  def logged_in?
    current_user.present?
  end

  def login_role
    session[:login_role] || current_user&.role
  end

  def require_login
    unless logged_in?
      redirect_to login_path, alert: 'Veuillez vous connecter'
    end
  end

  def require_role(role)
    unless login_role == role.to_s
      redirect_to dashboard_path, alert: 'Accès refusé'
    end
  end

  def require_agent
    require_role(:agence)
  end

  def require_agent_or_owner
    return if login_role == 'agence' || login_role == 'owner'
    redirect_to root_path, alert: 'Accès refusé'
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
