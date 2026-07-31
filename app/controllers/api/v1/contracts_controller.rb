module Api
  module V1
    class ContractsController < ApplicationController

      def index
        contracts = if current_user.agence?
                      Contract.joins(apartment: { building: :agency })
                        .where(agencies: { id: current_user.agency_id })
                        .order(created_at: :desc)
                    elsif current_user.tenant?
                      current_user.contracts.order(created_at: :desc)
                    else
                      Contract.none
                    end

        render json: { contracts: contracts.includes(:apartment, :tenant).map { |c| contract_response(c) } }
      end

      def show
        contract = if current_user.agence?
                     Contract.joins(apartment: { building: :agency })
                       .where(agencies: { id: current_user.agency_id })
                       .find(params[:id])
                   elsif current_user.tenant?
                     current_user.contracts.find(params[:id])
                   else
                     raise ActiveRecord::RecordNotFound
                   end

        render json: { contract: contract_response(contract) }
      end

      def create
        unless current_user.agence?
          return render json: { error: 'Accès refusé' }, status: :forbidden
        end

        apartment = Apartment.joins(:building)
          .where(buildings: { agency_id: current_user.agency_id })
          .find(params[:apartment_id])

        tenant = find_or_create_tenant

        contract = apartment.contracts.new(
          tenant: tenant,
          agency: current_user.agency,
          contract_number: params[:contract_number],
          content: params[:content],
          rent_amount: params[:rent_amount],
          start_date: params[:start_date],
          duration_months: params[:duration_months]
        )

        if contract.save
          render json: { contract: contract_response(contract) }, status: :created
        else
          render json: { errors: contract.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def sign
        unless current_user.tenant?
          return render json: { error: 'Accès refusé' }, status: :forbidden
        end

        contract = current_user.contracts.pending.find(params[:id])

        if params[:signature].blank?
          return render json: { error: 'Signature requise' }, status: :unprocessable_entity
        end

        contract.sign!(params[:signature])

        contract.apartment.update!(tenant: current_user, status: 'occupied')
        current_user.update!(building_id: contract.apartment.building_id) unless current_user.building_id.present?

        now = Date.current
        payment = contract.apartment.payments.find_or_initialize_by(month: now.month, year: now.year)
        payment.update!(
          tenant: current_user,
          amount: contract.rent_amount,
          due_date: Payment.default_due_date(now.year, now.month),
          status: 'pending'
        )

        render json: { contract: contract_response(contract), message: 'Contrat signé avec succès' }
      end

      private

      def find_or_create_tenant
        phone = params[:phone]
        user = User.find_by(phone: phone, role: 'tenant')

        unless user
          user = User.create!(
            phone: phone,
            role: 'tenant',
            first_name: params[:first_name].presence || 'Locataire',
            last_name: params[:last_name].presence || phone,
            email: params[:email].presence || "#{phone}@temp.loca",
            password: SecureRandom.hex(8)
          )
        end

        user
      end

      def contract_response(contract)
        {
          id: contract.id,
          contract_number: contract.contract_number,
          content: contract.content,
          rent_amount: contract.rent_amount,
          status: contract.status,
          tenant_signature: contract.tenant_signature,
          tenant_signed_at: contract.tenant_signed_at,
          start_date: contract.start_date,
          duration_months: contract.duration_months,
          created_at: contract.created_at,
          apartment: {
            id: contract.apartment.id,
            number: contract.apartment.number,
            building_name: contract.apartment.building.name,
            building_address: contract.apartment.building.address
          },
          tenant: {
            id: contract.tenant.id,
            name: contract.tenant.full_name,
            phone: contract.tenant.phone
          },
          agency: {
            id: contract.agency.id,
            name: contract.agency.name
          }
        }
      end
    end
  end
end
