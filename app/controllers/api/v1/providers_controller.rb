module Api
  module V1
    class ProvidersController < ApplicationController
      before_action :require_agent

      def index
        providers = current_user.agency.providers.order(:last_name)
        render json: { providers: providers.map { |p| provider_response(p) } }
      end

      def create
        provider = current_user.agency.providers.new(provider_params)
        if provider.save
          render json: { provider: provider_response(provider) }, status: :created
        else
          render json: { errors: provider.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        provider = current_user.agency.providers.find(params[:id])
        if provider.update(provider_params)
          render json: { provider: provider_response(provider) }
        else
          render json: { errors: provider.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        provider = current_user.agency.providers.find(params[:id])
        provider.destroy!
        render json: { message: 'Prestataire supprimé' }
      end

      private

      def provider_params
        params.require(:provider).permit(:first_name, :last_name, :phone, :trade)
      end

      def provider_response(provider)
        {
          id: provider.id,
          first_name: provider.first_name,
          last_name: provider.last_name,
          phone: provider.phone,
          trade: provider.trade
        }
      end
    end
  end
end
