class ApplicationController < ActionController::API
  before_action :authenticate_request

  private

  def authenticate_request
    header = request.headers['Authorization']
    token = header&.split(' ')&.last
    decoded = JwtService.decode(token)

    if decoded
      @current_user = User.find_by(id: decoded[:user_id])
    end

    render json: { error: 'Non autorisé' }, status: :unauthorized unless @current_user
  end

  def current_user
    @current_user
  end

  def require_role(role)
    unless current_user&.role == role.to_s
      render json: { error: 'Accès refusé' }, status: :forbidden
    end
  end
end
