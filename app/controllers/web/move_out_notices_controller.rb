class Web::MoveOutNoticesController < Web::ApplicationController
  before_action :require_tenant

  def new
    @apartment = current_user.apartments_as_tenant.first
    @notice = MoveOutNotice.new
  end

  def create
    @apartment = current_user.apartments_as_tenant.first

    unless @apartment
      redirect_to dashboard_tenant_path, alert: 'Aucun appartement trouvé'
      return
    end

    @notice = @apartment.move_out_notices.new(
      tenant: current_user,
      move_out_date: params[:move_out_notice][:move_out_date]
    )

    if @notice.save
      redirect_to dashboard_tenant_path, notice: 'Préavis de départ enregistré'
    else
      flash.now[:alert] = @notice.errors.full_messages.join(', ')
      render :new
    end
  end

  private

  def require_tenant
    require_role(:tenant)
  end
end
