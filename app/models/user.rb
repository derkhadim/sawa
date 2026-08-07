class User < ApplicationRecord
  has_secure_password

  ROLES = %w[super_admin agence tenant owner].freeze

  belongs_to :agency, optional: true
  belongs_to :building, optional: true
  belongs_to :owner, optional: true

  has_many :apartments_as_tenant, class_name: 'Apartment', foreign_key: :tenant_id
  has_many :payments, foreign_key: :tenant_id
  has_many :incidents, foreign_key: :tenant_id
  has_many :publications, foreign_key: :tenant_id
  has_many :move_out_notices, foreign_key: :tenant_id
  has_many :contracts, foreign_key: :tenant_id

  has_many :conversation_participants, dependent: :destroy
  has_many :conversations, through: :conversation_participants
  has_many :sent_messages, class_name: 'Message', foreign_key: :sender_id, dependent: :destroy

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :phone, presence: true, uniqueness: true
  validates :first_name, :last_name, presence: true, unless: :agence?
  validates :role, presence: true, inclusion: { in: ROLES }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || !password.nil? }

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

  # Révoque tous les tokens JWT émis avant cet appel.
  def revoke_jwt!
    increment!(:jwt_version)
  end

  # Génère un token de réinitialisation à usage unique (30 min).
  def generate_reset_token!
    token = SecureRandom.urlsafe_base64(32)
    self.reset_password_digest = BCrypt::Password.create(token)
    self.reset_password_sent_at = Time.current
    save!(validate: false)
    token
  end

  def reset_token_valid?(token)
    return false unless reset_password_digest.present?
    return false if reset_password_sent_at.blank? || reset_password_sent_at < 30.minutes.ago

    BCrypt::Password.new(reset_password_digest) == token
  rescue BCrypt::Errors::InvalidHash
    false
  end

  def consume_reset_token!
    update!(reset_password_digest: nil, reset_password_sent_at: nil)
    revoke_jwt!
  end

  def tenant_buildings
    Building.joins(:apartments).where(apartments: { tenant_id: id }).distinct
  end

  def has_apartment?
    tenant? && apartments_as_tenant.exists?
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
