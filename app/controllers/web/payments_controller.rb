class Web::PaymentsController < Web::ApplicationController
  include SecureUpload

  def index
    if params[:apartment_id]
      @apartment = find_apartment_in_scope
      @payments = @apartment.payments.order(year: :desc, month: :desc)
    else
      @payments = current_user.payments.includes(apartment: :building).order(year: :desc, month: :desc)
    end
  end

  def show
    @payment = find_in_agency(Payment)
  rescue ActiveRecord::RecordNotFound
    @payment = Payment.includes(apartment: :building).find(params[:id])
    unless current_user.id == @payment.tenant_id
      redirect_to root_path, alert: 'Accès refusé'
    end
  end

  def new
    @apartment = find_apartment_in_scope
    @payment = @apartment.payments.new
  end

  def create
    @apartment = find_apartment_in_scope

    unless current_user.tenant? && current_user.id == @apartment.tenant_id
      redirect_to @apartment, alert: 'Accès refusé'
      return
    end

    month = Time.current.month
    year = Time.current.year

    @payment = @apartment.payments.find_or_initialize_by(month: month, year: year)

    if @payment.status == 'paid'
      redirect_to new_apartment_payment_path(@apartment), alert: 'Ce mois est déjà payé'
      return
    end

    @payment.amount = @apartment.rent_amount
    @payment.due_date = Payment.default_due_date(year, month)
    @payment.reference = "PAY-#{year}#{format('%02d', month)}-#{@apartment.id}-#{current_user.id}"
    @payment.status = 'submitted'
    @payment.paid_at = nil
    @payment.tenant = current_user
    @payment.payment_method = params[:payment_method]

    if params[:proof].present?
      begin
        @payment.proof = save_proof(params[:proof])
      rescue SecureUpload::UploadError => e
        @payment.errors.add(:proof, e.message)
      end
    end

    if @payment.save
      redirect_to dashboard_tenant_path, notice: 'Preuve de paiement envoyée. En attente de validation.'
    else
      flash.now[:alert] = @payment.errors.full_messages.join(', ')
      render :new
    end
  end

  def pending_validation
    require_role(:agence)
    agency = current_user.agency
    apartment_ids = Apartment.where(building_id: agency.buildings.pluck(:id)).pluck(:id)
    @submitted_payments = Payment.submitted
                                 .where(apartment_id: apartment_ids)
                                 .includes(:tenant, :apartment)
                                 .order(created_at: :desc)
  end

  def agency_index
    require_role(:agence)
    agency = current_user.agency
    building_ids = agency.buildings.pluck(:id)
    apartment_ids = Apartment.where(building_id: building_ids).pluck(:id)

    @q = params[:q]
    @status = params[:status]
    @building_id = params[:building_id]

    @payments = Payment.where(apartment_id: apartment_ids)
                       .includes(:tenant, apartment: :building)
                       .order(year: :desc, month: :desc, created_at: :desc)

    @payments = @payments.where(status: @status) if @status.present?
    @payments = @payments.where(apartments: { building_id: @building_id }) if @building_id.present?

    @buildings = agency.buildings.order(:name)
  end

  def validate
    @payment = find_in_agency(Payment)

    attrs = { status: 'paid', paid_at: Time.current }
    attrs[:payment_method] = params[:payment_method] if params[:payment_method].present?

    if @payment.update(attrs)
      redirect_back fallback_location: dashboard_path, notice: 'Paiement validé — quittance disponible'
    else
      redirect_back fallback_location: dashboard_path, alert: 'Erreur lors de la validation'
    end
  end

  private

  def save_proof(file)
    ext = validate_upload!(file)
    filename = "proof_#{Time.now.to_i}_#{SecureRandom.hex(4)}.#{ext}"
    path = Rails.root.join('public', 'uploads', filename)
    File.open(path, 'wb') { |f| f.write(file.read) }
    "/uploads/#{filename}"
  end
end
