module Api
  module V1
    class DashboardController < ApplicationController
      def index
        return render json: { error: 'Accès refusé' }, status: :forbidden unless current_user.agence?

        agency = current_user.agency
        buildings = agency.buildings.includes(:apartments)
        now = Time.current
        current_month = now.month
        current_year = now.year

        recent_payments = Payment.where(
          apartment_id: Apartment.where(building_id: buildings.pluck(:id))
        ).where(year: current_year, month: current_month).paid.order(paid_at: :desc)

        late_payments = Payment.where(
          apartment_id: Apartment.where(building_id: buildings.pluck(:id))
        ).where(status: 'late').or(
          Payment.where(
            apartment_id: Apartment.where(building_id: buildings.pluck(:id))
          ).where(status: 'pending').where('due_date < ?', Date.today)
        ).order(due_date: :asc)

        buildings_stats = buildings.map do |b|
          total_rent = b.apartments.where(status: 'occupied').sum(:rent_amount)
          monthly_paid = Payment.for_building(b.id)
                                .for_month(current_month, current_year)
                                .paid.sum(:amount)

          recovery_percentage = total_rent > 0 ? ((monthly_paid / total_rent) * 100).round(2) : 0

          {
            id: b.id,
            name: b.name,
            total_monthly_rent: total_rent,
            monthly_collected: monthly_paid,
            recovery_percentage: recovery_percentage,
            total_apartments: b.apartments.size,
            occupied: b.occupied_apartments
          }
        end

        total_commission = Payment.paid
                                  .where(
                                    apartment_id: Apartment.where(building_id: buildings.pluck(:id))
                                  )
                                  .sum(:amount) * 0.07

        render json: {
          buildings: buildings_stats,
          recent_payments: recent_payments.limit(20).map { |p| payment_short(p) },
          late_payments: late_payments.limit(20).map { |p| payment_short(p) },
          commission_total: total_commission.round(2),
          month: current_month,
          year: current_year
        }
      end

      def admin
        return render json: { error: 'Accès refusé' }, status: :forbidden unless current_user.super_admin?

        agencies = Agency.all.map do |a|
          buildings = a.buildings.includes(:apartments)
          total_rent = 0
          total_collected = 0

          buildings.each do |b|
            total_rent += b.apartments.where(status: 'occupied').sum(:rent_amount)
            total_collected += Payment.for_building(b.id).paid.sum(:amount)
          end

          {
            id: a.id,
            name: a.name,
            total_buildings: buildings.size,
            total_apartments: buildings.map { |b| b.apartments.size }.sum,
            total_rent: total_rent,
            total_collected: total_collected
          }
        end

        total_platform_rent = agencies.sum { |a| a[:total_rent] }
        total_platform_collected = agencies.sum { |a| a[:total_collected] }

        render json: {
          agencies: agencies,
          platform_total_rent: total_platform_rent,
          platform_total_collected: total_platform_collected,
          platform_recovery_rate: total_platform_rent > 0 ? ((total_platform_collected / total_platform_rent) * 100).round(2) : 0,
          total_agencies: agencies.size
        }
      end

      def tenant
        return render json: { error: 'Accès refusé' }, status: :forbidden unless current_user.tenant?

        apartments = current_user.apartments_as_tenant.includes(:building)

        unless apartments.any?
          return render json: { apartments: [], message: 'Aucun appartement assigné' }
        end

        payments = current_user.payments.order(year: :desc, month: :desc)
        incidents = current_user.incidents.order(created_at: :desc)

        now = Time.current
        current_payment = payments.find_by(month: now.month, year: now.year)
        agency_user = apartments.first.building&.agency&.users&.first

        render json: {
          apartments: apartments.map { |apt|
            building = apt.building
            {
              id: apt.id,
              number: apt.number,
              rent_amount: apt.rent_amount,
              floor: apt.floor,
              building_name: building.name,
              building_address: building.address,
              building_id: building.id,
              agency_id: building.agency_id,
              agency_name: building.agency&.name
            }
          },
          agency: agency_user ? { id: agency_user.id, name: agency_user.full_name, phone: agency_user.phone } : nil,
          current_payment_status: current_payment&.status || 'pending',
          current_payment_id: current_payment&.id,
          last_payments: payments.limit(6).map { |p|
            { id: p.id, amount: p.amount, month: p.month, year: p.year, status: p.status, paid_at: p.paid_at, payment_method: p.payment_method, apartment_id: p.apartment_id }
          },
          recent_incidents: incidents.limit(5).map { |i|
            { id: i.id, title: i.title, status: i.status, created_at: i.created_at, apartment_id: i.apartment_id }
          }
        }
      end

      def owner
        return render json: { error: 'Accès refusé' }, status: :forbidden unless current_user.owner?

        owner = current_owner
        unless owner
          return render json: { error: 'Propriétaire introuvable' }, status: :not_found
        end

        buildings = owner.buildings.includes(:apartments)
        now = Time.current
        current_month = now.month
        current_year = now.year

        buildings_data = buildings.map do |b|
          apartments = b.apartments
          occupied = apartments.select(&:occupied?)
          total_rent = occupied.sum(&:rent_amount)
          monthly_paid = Payment.for_building(b.id)
                                .for_month(current_month, current_year)
                                .paid.sum(:amount)
          recovery = total_rent > 0 ? ((monthly_paid / total_rent) * 100).round(2) : 0

          incidents = Incident.where(apartment_id: apartments.pluck(:id))
                              .order(created_at: :desc)
                              .limit(10)

          {
            id: b.id,
            name: b.name,
            address: b.address,
            total_apartments: apartments.size,
            occupied_apartments: occupied.size,
            free_apartments: apartments.size - occupied.size - apartments.select(&:renovation?).size,
            renovation_apartments: apartments.select(&:renovation?).size,
            total_monthly_rent: total_rent,
            monthly_collected: monthly_paid,
            recovery_percentage: recovery,
            recent_incidents: incidents.map { |i|
              {
                id: i.id,
                title: i.title,
                status: i.status,
                created_at: i.created_at,
                apartment: i.apartment.number
              }
            }
          }
        end

        render json: {
          owner_name: "#{owner.first_name} #{owner.last_name}",
          buildings: buildings_data,
          total_buildings: buildings.size
        }
      end

      private

      def payment_short(payment)
        {
          id: payment.id,
          amount: payment.amount,
          month: payment.month,
          year: payment.year,
          status: payment.status,
          due_date: payment.due_date,
          paid_at: payment.paid_at,
          tenant: {
            name: "#{payment.tenant.first_name} #{payment.tenant.last_name}"
          },
          building: payment.apartment.building.name,
          apartment: payment.apartment.number
        }
      end
    end
  end
end
