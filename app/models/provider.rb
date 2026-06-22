class Provider < ApplicationRecord
  TRADES = %w[plombier électricien maçon peintre autre].freeze

  belongs_to :agency

  validates :first_name, :last_name, :phone, :trade, presence: true
  validates :trade, inclusion: { in: TRADES }
  validates :phone, uniqueness: { scope: :agency_id }

  def full_name
    "#{first_name} #{last_name}"
  end

  def full_name_with_trade
    "#{full_name} (#{trade})"
  end
end
