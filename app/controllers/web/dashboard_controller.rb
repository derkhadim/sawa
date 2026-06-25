class Web::DashboardController < Web::ApplicationController
  def index
    require_role(:agence)
    @agency = current_user.agency
    @buildings = @agency.buildings.includes(:apartments)
    @now = Time.current
    @current_month = @now.month
    @current_year = @now.year

    building_ids = @buildings.pluck(:id)
    apartment_ids = Apartment.where(building_id: building_ids).pluck(:id)

    @recent_payments = Payment.where(apartment_id: apartment_ids)
                              .where(year: @current_year, month: @current_month)
                              .paid.order(paid_at: :desc).limit(20)

    @late_payments = Payment.where(apartment_id: apartment_ids)
                            .where(status: 'late')
                            .or(Payment.where(apartment_id: apartment_ids)
                                       .where(status: 'pending')
                                       .where('due_date < ?', Date.today))
                            .order(due_date: :asc).limit(20)

    @buildings_stats = @buildings.map do |b|
      total_rent = b.apartments.where(status: 'occupied').sum(:rent_amount)
      monthly_paid = Payment.for_building(b.id).for_month(@current_month, @current_year).paid.sum(:amount)
      recovery = total_rent > 0 ? ((monthly_paid / total_rent) * 100).round(2) : 0

      { building: b, total_rent: total_rent, monthly_paid: monthly_paid, recovery: recovery }
    end

    @open_incidents_count = Incident.where(apartment_id: apartment_ids, status: 'open').count
    @submitted_payments_count = Payment.submitted.where(apartment_id: apartment_ids).count
  end

  def admin
    require_role(:super_admin)
    @agencies = Agency.all
    @total_platform_rent = 0
    @total_platform_collected = 0

    @agencies_stats = @agencies.map do |a|
      buildings = a.buildings
      total_rent = 0
      total_collected = 0

      buildings.each do |b|
        total_rent += b.apartments.where(status: 'occupied').sum(:rent_amount)
        total_collected += Payment.for_building(b.id).paid.sum(:amount)
      end

      @total_platform_rent += total_rent
      @total_platform_collected += total_collected

      { agency: a, total_buildings: buildings.size, total_rent: total_rent, total_collected: total_collected }
    end

    @platform_recovery_rate = @total_platform_rent > 0 ? ((@total_platform_collected / @total_platform_rent) * 100).round(2) : 0
  end

  def tenant
    require_role(:tenant)
    @apartment = current_user.apartments_as_tenant.first
    @payments = current_user.payments.order(year: :desc, month: :desc)
    @incidents = current_user.incidents.order(created_at: :desc)
    @building = @apartment&.building
    @current_payment = @payments.find_by(month: Time.current.month, year: Time.current.year)
  end

  def owner
    require_role(:owner)
    @owner = Owner.find_by(email: current_user.email)

    unless @owner
      redirect_to root_path, alert: 'Propriétaire introuvable'
      return
    end

    @buildings = @owner.buildings.includes(:apartments)
    @now = Time.current
    @current_month = @now.month
    @current_year = @now.year

    @buildings_stats = @buildings.map do |b|
      apartments = b.apartments
      occupied = apartments.select(&:occupied?)
      total_rent = occupied.sum(&:rent_amount)
      monthly_paid = Payment.for_building(b.id).for_month(@current_month, @current_year).paid.sum(:amount)
      recovery = total_rent > 0 ? ((monthly_paid / total_rent) * 100).round(2) : 0

      {
        building: b,
        total_apartments: apartments.size,
        occupied_apartments: occupied.size,
        free_apartments: apartments.size - occupied.size,
        total_rent: total_rent,
        monthly_paid: monthly_paid,
        recovery: recovery
      }
    end

    apartment_ids = Apartment.where(building_id: @buildings.pluck(:id)).pluck(:id)
    @recent_incidents = Incident.where(apartment_id: apartment_ids)
                                .includes(:apartment)
                                .order(created_at: :desc)
                                .limit(20)

    @agency_user = @buildings.first&.agency&.users&.first
  end
end
