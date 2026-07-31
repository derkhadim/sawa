class Web::ContractsController < Web::ApplicationController

  def new
    require_agent
    @apartment = Apartment.joins(:building)
      .where(buildings: { agency_id: current_user.agency_id })
      .find(params[:apartment_id])
    @contract = @apartment.contracts.new
  end

  def create
    require_agent
    @apartment = Apartment.joins(:building)
      .where(buildings: { agency_id: current_user.agency_id })
      .find(params[:apartment_id])

    tenant = find_or_create_tenant

    @contract = @apartment.contracts.new(
      tenant: tenant,
      agency: current_user.agency,
      contract_number: params[:contract][:contract_number],
      content: params[:contract][:content],
      rent_amount: params[:contract][:rent_amount],
      start_date: params[:contract][:start_date],
      duration_months: params[:contract][:duration_months]
    )

    if @contract.save
      redirect_to @apartment, notice: 'Contrat créé. En attente de la signature du locataire.'
    else
      render :new
    end
  end

  def index
    require_role(:tenant)
    @contracts = current_user.contracts.order(created_at: :desc).includes(:apartment)
  end

  def show
    @contract = if current_user.agence?
                  Contract.joins(apartment: { building: :agency })
                    .where(agencies: { id: current_user.agency_id })
                    .find(params[:id])
                elsif current_user.tenant?
                  current_user.contracts.find(params[:id])
                else
                  raise ActiveRecord::RecordNotFound
                end
  end

  def sign
    require_role(:tenant)
    @contract = current_user.contracts.pending.find(params[:id])

    if params[:signature].present?
      @contract.sign!(params[:signature])
      @contract.apartment.update!(tenant: current_user, status: 'occupied')
      current_user.update!(building_id: @contract.apartment.building_id) unless current_user.building_id.present?

      now = Date.current
      payment = @contract.apartment.payments.find_or_initialize_by(month: now.month, year: now.year)
      payment.update!(
        tenant: current_user,
        amount: @contract.rent_amount,
        due_date: Payment.default_due_date(now.year, now.month),
        status: 'pending'
      )

      redirect_to contract_path(@contract), notice: 'Contrat signé avec succès ! Bienvenue dans votre nouveau logement.'
    else
      flash.now[:alert] = 'Veuillez apposer votre signature'
      render :show
    end
  end

  private

  def find_or_create_tenant
    phone = params[:contract][:phone]
    user = User.find_by(phone: phone, role: 'tenant')

    unless user
      user = User.create!(
        phone: phone,
        role: 'tenant',
        first_name: params[:contract][:first_name].presence || 'Locataire',
        last_name: params[:contract][:last_name].presence || phone,
        email: params[:contract][:email].presence || "#{phone}@temp.loca",
        password: SecureRandom.hex(8)
      )
    end

    user.update!(
      first_name: params[:contract][:first_name].presence || user.first_name,
      last_name: params[:contract][:last_name].presence || user.last_name,
      email: params[:contract][:email].presence || user.email
    ) if params[:contract][:first_name].present? || params[:contract][:last_name].present?

    user
  end
end
