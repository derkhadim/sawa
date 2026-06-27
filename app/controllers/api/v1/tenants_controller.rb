module Api
  module V1
    class TenantsController < ApplicationController
      before_action :require_agent

      def rating
        tenant = current_user.agency.users.joins(:building).where(buildings: { agency_id: current_user.agency_id }).find(params[:id])

        if params[:rating].present? && [1, 2, 3].include?(params[:rating].to_i)
          tenant.update!(rating: params[:rating].to_i)
          render json: { tenant: { id: tenant.id, rating: tenant.rating, rating_label: tenant.rating_label } }
        else
          render json: { error: 'Rating invalide. Valeurs acceptées: 1, 2, 3' }, status: :unprocessable_entity
        end
      end

      def cash_payment
        tenant = current_user.agency.users.joins(:building).where(buildings: { agency_id: current_user.agency_id }).find(params[:id])
        apartment = if params[:apartment_id].present?
                      tenant.apartments_as_tenant.find_by(id: params[:apartment_id])
                    else
                      tenant.apartments_as_tenant.first
                    end

        unless apartment
          return render json: { error: 'Aucun appartement assigné' }, status: :unprocessable_entity
        end

        now = Date.current
        existing = Payment.find_by(apartment: apartment, month: now.month, year: now.year)

        payment = if existing
                    existing.update!(status: 'paid', paid_at: Time.current, payment_method: 'cash', proof: nil)
                    existing
                  else
                    Payment.create!(
                      amount: apartment.rent_amount,
                      month: now.month,
                      year: now.year,
                      due_date: Payment.default_due_date(now.year, now.month),
                      status: 'paid',
                      paid_at: Time.current,
                      payment_method: 'cash',
                      reference: "CASH-#{now.to_s(:number)}-#{apartment.id}",
                      apartment: apartment,
                      tenant: tenant
                    )
                  end

        render json: { payment: payment_response(payment), message: 'Paiement cash enregistré' }
      end

      private

      def payment_response(payment)
        apt = payment.apartment
        bld = apt.building
        {
          id: payment.id,
          amount: payment.amount,
          month: payment.month,
          year: payment.year,
          status: payment.status,
          paid_at: payment.paid_at,
          due_date: payment.due_date,
          reference: payment.reference,
          payment_method: payment.payment_method,
          apartment_id: payment.apartment_id,
          tenant: { id: payment.tenant_id, name: payment.tenant.full_name },
          apartment: {
            number: apt.number,
            floor: apt.floor,
            rent_amount: apt.rent_amount,
            building_name: bld.name,
            building_address: bld.address
          }
        }
      end
    end
  end
end
