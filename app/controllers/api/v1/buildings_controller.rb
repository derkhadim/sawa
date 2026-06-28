module Api
  module V1
    class BuildingsController < ApplicationController
      before_action :require_agent, except: [:index, :show]

      def index
        buildings = if current_user.agence?
                      current_user.agency.buildings.includes(:owner, :apartments)
                    elsif current_user.tenant?
                      current_user.tenant_buildings.includes(:apartments)
                    elsif current_user.owner?
                      current_owner ? current_owner.buildings.includes(:apartments) : Building.none
                    else
                      Building.none
                    end
        render json: { buildings: buildings.map { |b| building_response(b) } }
      end

      def show
        building = find_building
        render json: { building: building_detail(building) }
      end

      def create
        building = current_user.agency.buildings.new(building_params)

        if building.save
          render json: { building: building_response(building) }, status: :created
        else
          render json: { errors: building.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        building = current_user.agency.buildings.find(params[:id])

        if building.update(building_params)
          render json: { building: building_detail(building) }
        else
          render json: { errors: building.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def building_params
        params.require(:building).permit(
          :name, :address, :neighborhood, :commune,
          :latitude, :longitude, :owner_id, :photo
        )
      end

      def find_building
        if current_user.agence?
          current_user.agency.buildings.find(params[:id])
        elsif current_user.owner?
          current_owner ? current_owner.buildings.find(params[:id]) : (raise ActiveRecord::RecordNotFound)
        else
          raise ActiveRecord::RecordNotFound
        end
      end

      def building_response(building)
        {
          id: building.id,
          name: building.name,
          address: building.address,
          neighborhood: building.neighborhood,
          commune: building.commune,
          latitude: building.latitude,
          longitude: building.longitude,
          owner_name: building.owner&.full_name,
          photo_url: building.photo_url,
          total_apartments: building.apartments.size,
          occupied_apartments: building.occupied_apartments,
          free_apartments: building.free_apartments,
          renovation_apartments: building.renovation_apartments
        }
      end

      def building_detail(building)
        building_response(building).merge(
          apartments: building.apartments.map do |a|
            {
              id: a.id,
              number: a.number,
              floor: a.floor,
              rent_amount: a.rent_amount,
              status: a.status,
              visible: a.visible,
              photos: a.photo_list,
              tenant_name: a.tenant&.then { |t| "#{t.first_name} #{t.last_name}" },
              tenant_phone: a.tenant&.phone,
              tenant_email: a.tenant&.email
            }
          end
        )
      end
    end
  end
end
