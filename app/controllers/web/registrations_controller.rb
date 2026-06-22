class Web::RegistrationsController < Web::ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.role = params[:user][:role] || 'tenant'

    if @user.role == 'agence'
      agency_name = params[:user][:agency_name]
      if agency_name.blank?
        @user.errors.add(:base, "Le nom de l'agence est requis")
        flash.now[:alert] = "Le nom de l'agence est requis"
        render :new
        return
      end
      @user.agency = Agency.create!(name: agency_name)
    end

    if @user.save
      session[:user_id] = @user.id
      redirect_to after_login_path(@user), notice: 'Compte créé avec succès'
    else
      flash.now[:alert] = @user.errors.full_messages.join(', ')
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :phone, :password, :password_confirmation, :first_name, :last_name)
  end

  def after_login_path(user)
    case user.role
    when 'agence'      then dashboard_path
    when 'tenant'      then dashboard_tenant_path
    when 'owner'       then dashboard_owner_path
    else login_path
    end
  end
end
