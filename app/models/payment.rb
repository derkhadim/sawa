class Payment < ApplicationRecord
  ALLOWED_PROOF_EXTENSIONS = %w[jpg jpeg png gif webp].freeze

  belongs_to :apartment
  belongs_to :tenant, class_name: 'User'

  validates :amount, :month, :year, :due_date, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validates :month, inclusion: { in: 1..12 }
  validates :status, inclusion: { in: %w[pending paid late submitted] }
  validates :payment_method, inclusion: { in: %w[cash proof] }, allow_nil: true

  scope :paid, -> { where(status: 'paid') }
  scope :pending, -> { where(status: 'pending') }
  scope :late, -> { where(status: 'late') }
  scope :submitted, -> { where(status: 'submitted') }
  scope :for_month, ->(month, year) { where(month: month, year: year) }
  scope :for_building, ->(building_id) {
    joins(:apartment).where(apartments: { building_id: building_id })
  }

  def self.default_due_date(year, month)
    Date.new(year, month, 12)
  end

  def mark_late_if_due
    if due_date.past? && status == 'pending'
      update(status: 'late')
    end
  end

  after_save :recompute_tenant_rating, if: :saved_change_to_status?

  private

  def recompute_tenant_rating
    tenant.compute_rating!
  end
end
