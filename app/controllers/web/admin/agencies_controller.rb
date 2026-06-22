class Web::Admin::AgenciesController < Web::ApplicationController
  before_action :require_super_admin

  def index
    @agencies = Agency.all.includes(:users, :buildings, :owners)
  end

  private

  def require_super_admin
    require_role(:super_admin)
  end
end
