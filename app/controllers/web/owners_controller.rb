class Web::OwnersController < Web::ApplicationController
  before_action :require_agent

  def index
    @owners = current_user.agency.owners
  end

  def new
    @owner = Owner.new
  end

  def create
    @owner = current_user.agency.owners.new(owner_params)

    if @owner.save
      redirect_to owners_path, notice: 'Propriétaire ajouté'
    else
      flash.now[:alert] = @owner.errors.full_messages.join(', ')
      render :new
    end
  end

  def edit
    @owner = current_user.agency.owners.find(params[:id])
  end

  def update
    @owner = current_user.agency.owners.find(params[:id])

    if @owner.update(owner_params)
      redirect_to owners_path, notice: 'Propriétaire mis à jour'
    else
      flash.now[:alert] = @owner.errors.full_messages.join(', ')
      render :edit
    end
  end

  private

  def owner_params
    params.require(:owner).permit(:first_name, :last_name, :phone, :email)
  end

  def require_agent
    require_role(:agence)
  end
end
