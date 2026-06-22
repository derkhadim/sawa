class Apartment < ApplicationRecord
  belongs_to :building
  belongs_to :tenant, class_name: 'User', optional: true

  has_many :payments, dependent: :destroy
  has_many :incidents, dependent: :destroy
  has_many :move_out_notices, dependent: :destroy

  validates :number, :rent_amount, presence: true
  validates :number, uniqueness: { scope: :building_id }
  validates :rent_amount, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[free occupied renovation] }

  def photo_list
    parsed =
      if photos.is_a?(::Array)
        photos
      elsif photos.present?
        JSON.parse(photos) rescue []
      else
        []
      end
    parsed.size >= 4 ? parsed.take(4) : parsed + Array.new(4 - parsed.size, '/uploads/placeholder.jpg')
  end

  def occupied?
    status == 'occupied'
  end

  def renovation?
    status == 'renovation'
  end

  def current_month_payment
    now = Time.current
    payments.find_by(month: now.month, year: now.year)
  end
end
