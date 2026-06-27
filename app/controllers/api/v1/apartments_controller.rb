module Api
  module V1
    class ApartmentsController < ApplicationController
      before_action :require_agent, except: [:show, :index]

      def index
        building = find_building_in_scope
        apartments = building.apartments.includes(:tenant)
        render json: { apartments: apartments.map { |a| apartment_response(a) } }
      end

      def show
        apartment = find_apartment_in_scope
        render json: { apartment: apartment_detail(apartment) }
      end

      def create
        building = current_user.agency.buildings.find(params[:building_id])
        apartment = building.apartments.new(apartment_params)

        if apartment.save
          render json: { apartment: apartment_response(apartment) }, status: :created
        else
          render json: { errors: apartment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        apartment = current_user.agency.apartments.joins(:building).find(params[:id])
        handle_photos_upload(apartment) if params[:apartment][:photos].present?

        if apartment.update(apartment_params)
          render json: { apartment: apartment_detail(apartment) }
        else
          render json: { errors: apartment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def assign_tenant
        apartment = current_user.agency.apartments.joins(:building).find(params[:id])

        if apartment.occupied?
          return render json: { error: 'Appartement déjà occupé' }, status: :unprocessable_entity
        end

        tenant = User.find_by(phone: params[:phone], role: 'tenant')

        unless tenant
          tenant = User.new(
            phone: params[:phone],
            role: 'tenant',
            first_name: params[:first_name] || 'Locataire',
            last_name: params[:last_name] || phone,
            email: params[:email] || "#{params[:phone]}@temp.loca",
            password: SecureRandom.hex(8),
            building_id: apartment.building_id
          )
          tenant.save!
        end

        apartment.update!(tenant: tenant, status: 'occupied')
        tenant.update!(building_id: apartment.building_id)

        # Create pending payment for current month
        now = Time.current
        apartment.payments.create!(
          tenant: tenant,
          amount: apartment.rent_amount,
          due_date: Payment.default_due_date(now.year, now.month),
          month: now.month,
          year: now.year,
          status: 'pending'
        )

        render json: { apartment: apartment_detail(apartment), tenant: { id: tenant.id, name: "#{tenant.first_name} #{tenant.last_name}", phone: tenant.phone } }
      end

      def unassign_tenant
        apartment = current_user.agency.apartments.joins(:building).find(params[:id])

        unless apartment.occupied?
          return render json: { error: 'Appartement déjà libre' }, status: :unprocessable_entity
        end

        tenant = apartment.tenant
        apartment.update!(tenant: nil, status: 'free')
        tenant.update!(building_id: nil)

        render json: { apartment: apartment_detail(apartment), message: "Locataire #{tenant.full_name} désassigné" }
      end

      def destroy
        apartment = current_user.agency.apartments.joins(:building).find(params[:id])
        apartment.destroy!
        render json: { message: 'Appartement supprimé' }
      end

      private

      def apartment_params
        params.require(:apartment).permit(:number, :floor, :rent_amount, :status, :visible)
      end

      def handle_photos_upload(apartment)
        uploaded_files = Array(params[:apartment][:photos])
        paths = uploaded_files.first(4).map do |file|
          next unless file.respond_to?(:original_filename)
          ext = safe_extension(file.original_filename)
          filename = "apt_#{apartment.id}_#{SecureRandom.hex(4)}.#{ext}"
          path = Rails.root.join('public', 'uploads', filename)
          File.open(path, 'wb') { |f| f.write(file.read) }
          "/uploads/#{filename}"
        end.compact
        apartment.photos = paths.to_json
      end

      def safe_extension(filename)
        ext = filename.split('.').last&.downcase
        %w[jpg jpeg png gif webp].include?(ext) ? ext : 'jpg'
      end

      def apartment_response(apartment)
        {
          id: apartment.id,
          number: apartment.number,
          floor: apartment.floor,
          rent_amount: apartment.rent_amount,
          status: apartment.status,
          visible: apartment.visible,
          building_id: apartment.building_id,
          photos: apartment.photo_list,
          tenant: apartment.tenant&.then { |t| { id: t.id, name: "#{t.first_name} #{t.last_name}", phone: t.phone } }
        }
      end

      def apartment_detail(apartment)
        apartment_response(apartment).merge(
          payments: apartment.payments.order(year: :desc, month: :desc).map do |p|
            { id: p.id, amount: p.amount, month: p.month, year: p.year, status: p.status, paid_at: p.paid_at, due_date: p.due_date }
          end,
          incidents: apartment.incidents.order(created_at: :desc).map do |i|
            { id: i.id, title: i.title, status: i.status, created_at: i.created_at }
          end
        )
      end
    end
  end
end
