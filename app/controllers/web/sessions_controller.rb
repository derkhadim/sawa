class Web::SessionsController < Web::ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
    redirect_to dashboard_path if logged_in?
  end

  def create
    user = User.find_by(phone: params[:phone])

    if user&.authenticate(params[:password])
      login_role = params[:login_role] || user.role

      unless role_available?(user, login_role)
        flash.now[:alert] = t("login.role_unavailable", role: t("roles.#{login_role}"))
        render :new
        return
      end

      session[:user_id] = user.id
      session[:login_role] = login_role
      redirect_to after_login_path(user, login_role)
    else
      flash.now[:alert] = t("login.invalid_credentials")
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    session[:login_role] = nil
    redirect_to login_path, notice: 'Déconnecté'
  end

  private

  PUBLIC_ROLES = %w[tenant owner agence super_admin].freeze

  def role_available?(user, login_role)
    unless PUBLIC_ROLES.include?(login_role)
      return false
    end
    case login_role
    when 'owner' then user.role == 'owner' || user.owner.present?
    when 'tenant' then user.role == 'tenant' || user.building_id.present?
    else user.role == login_role
    end
  end

  def after_login_path(user, login_role)
    case login_role
    when 'super_admin' then dashboard_admin_path
    when 'agence'      then dashboard_path
    when 'tenant'      then dashboard_tenant_path
    when 'owner'       then dashboard_owner_path
    else dashboard_path
    end
  end
end
