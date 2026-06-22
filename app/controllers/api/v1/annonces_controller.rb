module Api
  module V1
    class AnnoncesController < ApplicationController
      skip_before_action :authenticate_request, only: [:index, :show]
      before_action :set_current_user_if_token, only: [:index]

      def index
        apartments = Apartment.where(status: 'free', visible: true).includes(:building).order(created_at: :desc)

        if @current_user&.agence?
          agency_building_ids = @current_user.agency.buildings.pluck(:id)
          apartments = apartments.where(building_id: agency_building_ids)
        end

        render json: {
          annonces: apartments.map do |a|
            {
              id: a.id,
              number: a.number,
              floor: a.floor,
              rent_amount: a.rent_amount,
              status: a.status,
              building_name: a.building.name,
              building_address: a.building.address,
              photos: a.photo_list,
              created_at: a.created_at
            }
          end
        }
      end

      def show
        apartment = Apartment.includes(:building).find(params[:id])
        render json: {
          annonce: {
            id: apartment.id,
            number: apartment.number,
            floor: apartment.floor,
            rent_amount: apartment.rent_amount,
            status: apartment.status,
            building_name: apartment.building.name,
            building_address: apartment.building.address,
            photos: apartment.photo_list
          }
        }
      end

      private

      def set_current_user_if_token
        header = request.headers['Authorization']
        token = header&.split(' ')&.last
        decoded = JwtService.decode(token)
        @current_user = User.find_by(id: decoded[:user_id]) if decoded
      end
    end
  end
end
