module Authorization
  extend ActiveSupport::Concern

  private

  def find_in_agency(scope)
    if current_user.agence?
      scope.joins(apartment: { building: :agency })
           .where(agencies: { id: current_user.agency_id })
           .find(params[:id])
    elsif current_user.owner?
      owner = Owner.find_by(email: current_user.email)
      building_ids = owner&.buildings&.pluck(:id) || []
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
      owner = Owner.find_by(email: current_user.email)
      building_ids = owner&.buildings&.pluck(:id) || []
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
      current_user.agency.apartments.joins(:building).find(params[:apartment_id] || params[:id])
    elsif current_user.owner?
      owner = Owner.find_by(email: current_user.email)
      Apartment.where(building_id: owner&.buildings&.pluck(:id) || []).find(params[:apartment_id] || params[:id])
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
      owner = Owner.find_by(email: current_user.email)
      Building.where(id: owner&.buildings&.pluck(:id) || []).find(params[:building_id] || params[:id])
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
      owner = Owner.find_by(email: current_user.email)
      building_ids = owner&.buildings&.pluck(:id) || []
      Publication.where(building_id: building_ids).find(params[:id])
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
