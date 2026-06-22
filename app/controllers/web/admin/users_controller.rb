class Web::Admin::UsersController < Web::ApplicationController
  before_action :require_super_admin

  def index
    @users = User.all.includes(:agency, :building).order(created_at: :desc)
  end

  private

  def require_super_admin
    require_role(:super_admin)
  end
end
