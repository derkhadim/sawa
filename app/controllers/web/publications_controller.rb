class Web::PublicationsController < Web::ApplicationController
  include Authorization

  def index
    @building = find_building_in_scope

    @publications = @building.publications.recent.includes(:tenant, :likes)
    @publication = @building.publications.new
  end

  def agent_index
    require_role(:agence)
    @agency = current_user.agency
    building_ids = @agency.buildings.pluck(:id)
    @publications = Publication.where(building_id: building_ids).recent.includes(:tenant, :building, :likes)
  end

  def show
    @publication = find_publication_in_scope
    @comments = @publication.comments.recent.includes(:user)
    @comment = @publication.comments.new
  end

  def like
    @publication = find_publication_in_scope

    unless current_user.tenant? || current_user.agence?
      redirect_back fallback_location: root_path, alert: 'Accès refusé'
      return
    end

    like = @publication.likes.find_by(user: current_user)

    if like
      like.destroy
      redirect_back fallback_location: publication_path(@publication), notice: 'Like retiré'
    else
      @publication.likes.create!(user: current_user)
      redirect_back fallback_location: publication_path(@publication), notice: 'Publication aimée'
    end
  end

  def create
    @building = find_building_in_scope

    unless current_user.tenant? && current_user.tenant_buildings.ids.include?(@building.id) ||
           current_user.agence? && current_user.agency.buildings.exists?(@building.id)
      redirect_to @building, alert: 'Accès refusé'
      return
    end

    @publication = @building.publications.new(content: params[:publication][:content], tenant: current_user)

    if @publication.save
      redirect_to building_publications_path(@building), notice: 'Publication créée'
    else
      @publications = @building.publications.recent.includes(:tenant)
      flash.now[:alert] = @publication.errors.full_messages.join(', ')
      render :index
    end
  end
end
