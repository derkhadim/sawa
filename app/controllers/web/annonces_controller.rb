class Web::AnnoncesController < Web::ApplicationController
  skip_before_action :require_login, only: [:index, :show]

  def index
    @apartments = Apartment.where(status: 'free')
                           .includes(:building)
                           .order(created_at: :desc)

    if logged_in? && current_user.agence?
      agency_building_ids = current_user.agency.buildings.pluck(:id)
      @apartments = @apartments.where(building_id: agency_building_ids)
    end
  end

  def show
    @apartment = Apartment.where(status: 'free').includes(:building).find(params[:id])
  end
end
