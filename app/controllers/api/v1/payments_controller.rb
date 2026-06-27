module Api
  module V1
    class PaymentsController < ApplicationController
      before_action :require_agent, only: [:index]

      def index
        apartment = find_apartment_in_scope
        payments = apartment.payments.includes(:tenant).order(year: :desc, month: :desc)
        render json: { payments: payments.map { |p| payment_response(p) } }
      end

      def show
        payment = find_in_agency(Payment)
        render json: { payment: payment_response(payment) }
      rescue ActiveRecord::RecordNotFound
        payment = Payment.includes(apartment: :building).find(params[:id])
        unless current_user.id == payment.tenant_id
          return render json: { error: 'Accès refusé' }, status: :forbidden
        end
        render json: { payment: payment_response(payment) }
      end

      def create
        apartment = find_apartment_in_scope

        unless current_user.tenant? && current_user.id == apartment.tenant_id
          return render json: { error: 'Accès refusé' }, status: :forbidden
        end

        month = Time.current.month
        year = Time.current.year

        payment = apartment.payments.find_or_initialize_by(
          month: month,
          year: year,
          tenant: current_user
        )

        if payment.status == 'paid'
          return render json: { error: 'Ce mois est déjà payé' }, status: :unprocessable_entity
        end

        payment.amount = apartment.rent_amount
        payment.due_date = Payment.default_due_date(year, month)
        payment.reference = "PAY-#{year}#{format('%02d', month)}-#{apartment.id}-#{current_user.id}"
        payment.status = 'submitted'
        payment.paid_at = nil
        payment.payment_method = params[:payment_method] if params[:payment_method].present?

        if params[:proof].present?
          payment.proof = save_proof_file(params[:proof])
        end

        if payment.save
          render json: { payment: payment_response(payment), message: 'Preuve envoyée. En attente de validation.' }
        else
          render json: { errors: payment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def validate
        payment = find_in_agency(Payment)

        attrs = { status: 'paid', paid_at: Time.current }
        attrs[:payment_method] = params[:payment_method] if params[:payment_method].present?

        if payment.update(attrs)
          render json: { payment: payment_response(payment), message: 'Paiement validé' }
        else
          render json: { errors: payment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def save_proof_file(file)
        ext = safe_extension(file.original_filename)
        filename = "proof_#{Time.now.to_i}_#{SecureRandom.hex(4)}.#{ext}"
        path = Rails.root.join('public', 'uploads', filename)
        File.open(path, 'wb') { |f| f.write(file.read) }
        "/uploads/#{filename}"
      end

      def safe_extension(filename)
        ext = filename.split('.').last&.downcase
        return 'jpg' unless ext && Payment::ALLOWED_PROOF_EXTENSIONS.include?(ext)
        ext
      end

      def jsonInt(val)
        val.present? ? val.to_i : nil
      rescue
        nil
      end

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
          proof: payment.proof,
          payment_method: payment.payment_method,
          apartment_id: payment.apartment_id,
          tenant: {
            id: payment.tenant_id,
            name: "#{payment.tenant.first_name} #{payment.tenant.last_name}"
          },
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
