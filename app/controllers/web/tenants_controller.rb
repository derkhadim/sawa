class Web::TenantsController < Web::ApplicationController
  before_action :require_agent, only: [:rating, :cash_payment]

  def show
    @tenant = if login_role == 'agence'
                User.joins(building: :agency).where(agencies: { id: current_user.agency_id }).find(params[:id])
              else
                owner = Owner.find_by(email: current_user.email)
                building_ids = owner ? owner.buildings.pluck(:id) : []
                User.where(building_id: building_ids).find(params[:id])
              end
    @apartments = @tenant.apartments_as_tenant.includes(:building)
    @payments = @tenant.payments.includes(:apartment).order(year: :desc, month: :desc).limit(12)
    @incidents = @tenant.incidents.includes(:apartment).order(created_at: :desc).limit(10)
  end

  def rating
    @tenant = User.joins(building: :agency).where(agencies: { id: current_user.agency_id }).find(params[:id])

    if params[:rating].present? && [1, 2, 3].include?(params[:rating].to_i)
      @tenant.update!(rating: params[:rating].to_i)
      redirect_to tenant_path(@tenant), notice: "Note mise à jour : #{@tenant.rating_label}"
    else
      redirect_to tenant_path(@tenant), alert: 'Note invalide'
    end
  end

  def cash_payment
    @tenant = User.joins(building: :agency).where(agencies: { id: current_user.agency_id }).find(params[:id])
    apartment = @tenant.apartments_as_tenant.find_by(id: params[:apartment_id]) || @tenant.apartments_as_tenant.first

    unless apartment
      redirect_to tenant_path(@tenant), alert: 'Ce locataire n\'a pas d\'appartement assigné'
      return
    end

    now = Date.current
    existing = Payment.find_by(apartment: apartment, month: now.month, year: now.year)

    if existing
      existing.update!(status: 'paid', paid_at: Time.current, payment_method: 'cash', proof: nil)
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
        tenant: @tenant
      )
    end

    redirect_to tenant_path(@tenant), notice: "Paiement cash enregistré pour #{apartment.rent_amount} FCFA"
  end
end
