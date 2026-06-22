module Api
  module V1
    class MoveOutNoticesController < ApplicationController
      before_action :require_tenant

      def create
        apartment = current_user.apartments_as_tenant.first

        unless apartment
          return render json: { error: 'Aucun appartement trouvé' }, status: :not_found
        end

        notice = apartment.move_out_notices.new(
          tenant: current_user,
          move_out_date: params[:move_out_date]
        )

        if notice.save
          render json: {
            notice: {
              id: notice.id,
              move_out_date: notice.move_out_date,
              apartment_id: notice.apartment_id,
              created_at: notice.created_at
            },
            message: 'Préavis de départ enregistré avec succès'
          }, status: :created
        else
          render json: { errors: notice.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def require_tenant
        require_role(:tenant)
      end
    end
  end
end
