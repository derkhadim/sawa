module Api
  module V1
    class OwnersController < ApplicationController
      before_action :require_agent

      def index
        owners = Owner.joins(:buildings).where(buildings: { agency_id: current_user.agency_id }).distinct
        render json: { owners: owners.as_json(only: [:id, :first_name, :last_name, :phone, :email]) }
      end

      def show
        owner = Owner.joins(:buildings).where(buildings: { agency_id: current_user.agency_id }).find(params[:id])
        render json: { owner: owner_with_buildings(owner) }
      end

      def create
        owner = Owner.new(owner_params)

        if owner.save
          render json: { owner: owner }, status: :created
        else
          render json: { errors: owner.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        owner = Owner.joins(:buildings).where(buildings: { agency_id: current_user.agency_id }).find(params[:id])

        if owner.update(owner_params)
          render json: { owner: owner_with_buildings(owner) }
        else
          render json: { errors: owner.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def owner_params
        params.require(:owner).permit(:first_name, :last_name, :phone, :email)
      end

      def require_agent
        require_role(:agence)
      end

      def owner_with_buildings(owner)
        owner.as_json(
          only: [:id, :first_name, :last_name, :phone, :email],
          include: { buildings: { only: [:id, :name, :address, :neighborhood, :commune] } }
        )
      end
    end
  end
end
