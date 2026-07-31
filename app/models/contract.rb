class Contract < ApplicationRecord
  belongs_to :apartment
  belongs_to :tenant, class_name: 'User'
  belongs_to :agency

  validates :contract_number, :rent_amount, presence: true
  validates :contract_number, uniqueness: true
  validates :rent_amount, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[pending_tenant signed] }

  scope :pending, -> { where(status: 'pending_tenant') }
  scope :signed, -> { where(status: 'signed') }

  def pending?
    status == 'pending_tenant'
  end

  def signed?
    status == 'signed'
  end

  def sign!(signature_data)
    update!(
      tenant_signature: signature_data,
      tenant_signed_at: Time.current,
      status: 'signed'
    )
  end
end
