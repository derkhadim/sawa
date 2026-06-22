class Web::Pro::SessionsController < Web::ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  PRO_ROLES = %w[agence super_admin].freeze

  def new
    redirect_to dashboard_path if logged_in?
  end

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      login_role = params[:login_role] || user.role

      unless PRO_ROLES.include?(login_role) && user.role == login_role
        flash.now[:alert] = 'Accès réservé aux professionnels'
        render :new
        return
      end

      session[:user_id] = user.id
      session[:login_role] = login_role
      redirect_to after_login_path(login_role)
    else
      flash.now[:alert] = 'Email ou mot de passe invalide'
      render :new
    end
  end

  private

  def after_login_path(login_role)
    case login_role
    when 'super_admin' then dashboard_admin_path
    when 'agence'      then dashboard_path
    else login_path
    end
  end
end
