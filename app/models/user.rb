class User < ApplicationRecord
  has_secure_password

  ROLES = %w[super_admin agence tenant owner].freeze

  belongs_to :agency, optional: true
  belongs_to :building, optional: true

  has_many :apartments_as_tenant, class_name: 'Apartment', foreign_key: :tenant_id
  has_many :payments, foreign_key: :tenant_id
  has_many :incidents, foreign_key: :tenant_id
  has_many :publications, foreign_key: :tenant_id
  has_many :move_out_notices, foreign_key: :tenant_id

  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true, uniqueness: true
  validates :first_name, :last_name, presence: true, unless: :agence?
  validates :role, presence: true, inclusion: { in: ROLES }

  def agence?
    role == 'agence'
  end

  def tenant?
    role == 'tenant'
  end

  def super_admin?
    role == 'super_admin'
  end

  def owner?
    role == 'owner'
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  RATINGS = { excellent: 3, solvable: 2, douteux: 1 }.freeze

  def rating_label
    case rating
    when 3 then 'Excellent'
    when 2 then 'Solvable'
    when 1 then 'Douteux'
    end
  end

  def rating_badge_class
    case rating
    when 3 then 'badge-success'
    when 2 then 'badge-primary'
    when 1 then 'badge-destructive'
    else 'badge-secondary'
    end
  end

  def compute_rating!
    now = Date.current
    year_payments = payments.where(year: now.year)

    late_count = year_payments.where(status: 'late').count
    unpaid_months = (1..now.month).count { |m| !year_payments.where(month: m).where(status: ['paid', 'late', 'submitted']).exists? }

    if late_count == 0 && unpaid_months == 0
      update!(rating: 3)
    elsif late_count >= 4 || unpaid_months >= 3
      update!(rating: 1)
    else
      update!(rating: 2)
    end
  end
end
