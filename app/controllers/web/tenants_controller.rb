class Web::TenantsController < Web::ApplicationController
  before_action :require_agent, only: [:rating, :cash_payment]

  def show
    @tenant = if login_role == 'agence'
                User.joins(apartments_as_tenant: { building: :agency })
                    .where(agencies: { id: current_user.agency_id })
                    .find(params[:id])
              else
                building_ids = current_owner ? current_owner.buildings.pluck(:id) : []
                User.joins(:apartments_as_tenant)
                    .where(apartments: { building_id: building_ids })
                    .find(params[:id])
              end
    @apartments = @tenant.apartments_as_tenant.includes(:building)
    @payments = @tenant.payments.includes(:apartment).order(year: :desc, month: :desc).limit(12)
    @incidents = @tenant.incidents.includes(:apartment).order(created_at: :desc).limit(10)
  end

  def rating
    @tenant = User.joins(apartments_as_tenant: { building: :agency })
                  .where(agencies: { id: current_user.agency_id })
                  .find(params[:id])

    if params[:rating].present? && [1, 2, 3].include?(params[:rating].to_i)
      @tenant.update!(rating: params[:rating].to_i)
      redirect_to tenant_path(@tenant), notice: "Note mise à jour : #{@tenant.rating_label}"
    else
      redirect_to tenant_path(@tenant), alert: 'Note invalide'
    end
  end

  def cash_payment
    @tenant = User.joins(apartments_as_tenant: { building: :agency })
                  .where(agencies: { id: current_user.agency_id })
                  .find(params[:id])
    apartment = @tenant.apartments_as_tenant.find_by(id: params[:apartment_id]) || @tenant.apartments_as_tenant.first

    unless apartment
      redirect_to tenant_path(@tenant), alert: 'Ce locataire n\'a pas d\'appartement assigné'
      return
    end

    now = Date.current
    payment = Payment.find_or_initialize_by(apartment: apartment, month: now.month, year: now.year)
    payment.update!(
      status: 'paid',
      paid_at: Time.current,
      payment_method: 'cash',
      proof: nil,
      amount: apartment.rent_amount,
      due_date: Payment.default_due_date(now.year, now.month),
      tenant: @tenant,
      reference: payment.reference.presence || "CASH-#{now.strftime('%Y%m%d')}-#{apartment.id}"
    )

    redirect_to payment_path(payment), notice: "Paiement en espèces de #{apartment.rent_amount} FCFA enregistré — quittance disponible"
  end
end
