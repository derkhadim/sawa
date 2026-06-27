class Web::MoveOutNoticesController < Web::ApplicationController
  before_action :require_tenant

  def new
    @apartments = current_user.apartments_as_tenant.includes(:building)
    @notice = MoveOutNotice.new
  end

  def create
    @apartment = current_user.apartments_as_tenant.find_by(id: params[:apartment_id])

    unless @apartment
      redirect_to dashboard_tenant_path, alert: 'Appartement introuvable'
      return
    end

    @notice = @apartment.move_out_notices.new(
      tenant: current_user,
      move_out_date: params[:move_out_notice][:move_out_date]
    )

    if @notice.save
      redirect_to dashboard_tenant_path, notice: 'Préavis de départ enregistré'
    else
      @apartments = current_user.apartments_as_tenant.includes(:building)
      flash.now[:alert] = @notice.errors.full_messages.join(', ')
      render :new
    end
  end

  private

  def require_tenant
    require_role(:tenant)
  end
end
