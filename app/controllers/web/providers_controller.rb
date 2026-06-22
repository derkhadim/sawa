class Web::ProvidersController < Web::ApplicationController
  before_action :require_agent

  def index
    @providers = current_user.agency.providers.order(:last_name)
  end

  def new
    @provider = current_user.agency.providers.new
  end

  def create
    @provider = current_user.agency.providers.new(provider_params)
    if @provider.save
      redirect_to providers_path, notice: 'Prestataire ajouté'
    else
      flash.now[:alert] = @provider.errors.full_messages.join(', ')
      render :new
    end
  end

  def edit
    @provider = current_user.agency.providers.find(params[:id])
  end

  def update
    @provider = current_user.agency.providers.find(params[:id])
    if @provider.update(provider_params)
      redirect_to providers_path, notice: 'Prestataire mis à jour'
    else
      flash.now[:alert] = @provider.errors.full_messages.join(', ')
      render :edit
    end
  end

  def destroy
    @provider = current_user.agency.providers.find(params[:id])
    @provider.destroy!
    redirect_to providers_path, notice: 'Prestataire supprimé'
  end

  private

  def provider_params
    params.require(:provider).permit(:first_name, :last_name, :phone, :trade)
  end
end
