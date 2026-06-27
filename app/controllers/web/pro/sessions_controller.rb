class Web::Pro::SessionsController < Web::ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
    if logged_in?
      redirect_to dashboard_path
    else
      render :new
    end
  end

  def create
    user = User.find_by(phone: params[:phone])

    if user&.authenticate(params[:password])
      login_role = params[:login_role] || user.role

      unless login_role == 'super_admin' && user.role == 'super_admin'
        flash.now[:alert] = 'Accès réservé aux super administrateurs'
        render :new
        return
      end

      session[:user_id] = user.id
      session[:login_role] = login_role
      redirect_to after_login_path(login_role)
    else
      flash.now[:alert] = 'Téléphone ou mot de passe invalide'
      render :new
    end
  end

  private

  def after_login_path(login_role)
    case login_role
    when 'super_admin' then dashboard_admin_path
    else login_path
    end
  end
end
