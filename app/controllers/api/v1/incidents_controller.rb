module Api
  module V1
    class IncidentsController < ApplicationController

      def index
        apartment = find_apartment_in_scope

        incidents = if current_user.agence?
                      apartment.incidents
                    else
                      apartment.incidents.where(tenant: current_user)
                    end

        render json: { incidents: incidents.order(created_at: :desc).map { |i| incident_response(i) } }
      end

      def show
        incident = if current_user.agence?
                     find_in_agency(Incident)
                   else
                     current_user.incidents.find(params[:id])
                   end

        render json: { incident: incident_response(incident) }
      end

      def create
        apartment = find_apartment_in_scope

        unless current_user.tenant? && current_user.id == apartment.tenant_id
          return render json: { error: 'Accès refusé' }, status: :forbidden
        end

        incident = apartment.incidents.new(
          tenant: current_user,
          title: params[:title],
          description: params[:description]
        )

        if incident.save
          render json: { incident: incident_response(incident) }, status: :created
        else
          render json: { errors: incident.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        incident = if current_user.agence?
                     find_in_agency(Incident)
                   else
                     current_user.incidents.find(params[:id])
                   end

        unless current_user.agence? || current_user.id == incident.tenant_id
          return render json: { error: 'Accès refusé' }, status: :forbidden
        end

        if incident.update(incident_update_params)
          render json: { incident: incident_response(incident) }
        else
          render json: { errors: incident.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def incident_update_params
        if current_user.agence?
          params.permit(:status, :provider_id)
        else
          params.permit(:status)
        end
      end

      def incident_response(incident)
        data = {
          id: incident.id,
          title: incident.title,
          description: incident.description,
          status: incident.status,
          created_at: incident.created_at,
          apartment_id: incident.apartment_id,
          apartment_number: incident.apartment.number,
          building_name: incident.apartment.building.name,
          tenant: {
            id: incident.tenant_id,
            name: "#{incident.tenant.first_name} #{incident.tenant.last_name}",
            phone: incident.tenant.phone
          }
        }
        if incident.provider
          data[:provider] = {
            id: incident.provider.id,
            name: "#{incident.provider.first_name} #{incident.provider.last_name}",
            trade: incident.provider.trade,
            phone: incident.provider.phone
          }
          data[:provider_id] = incident.provider_id
        end
        data
      end
    end
  end
end
