class Web::ApplicationController < ActionController::Base
  layout 'application'
  before_action :require_login

  helper_method :current_user, :logged_in?, :login_role

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def login_role
    session[:login_role] || current_user&.role
  end

  def require_login
    unless logged_in?
      redirect_to login_path, alert: 'Veuillez vous connecter'
    end
  end

  def require_role(role)
    unless login_role == role.to_s
      redirect_to dashboard_path, alert: 'Accès refusé'
    end
  end

  def require_agent
    require_role(:agence)
  end

  def require_agent_or_owner
    return if login_role == 'agence' || login_role == 'owner'
    redirect_to root_path, alert: 'Accès refusé'
  end
end
