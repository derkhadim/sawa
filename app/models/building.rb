class Building < ApplicationRecord
  belongs_to :owner
  belongs_to :agency
  has_many :apartments, dependent: :destroy
  has_many :publications, dependent: :destroy
  has_many :users

  validates :name, :address, presence: true

  def photo_url
    photo.presence || '/uploads/placeholder.jpg'
  end

  def total_rent
    apartments.sum(:rent_amount)
  end

  def occupied_apartments
    apartments.where(status: 'occupied').count
  end

  def free_apartments
    apartments.where(status: 'free').count
  end

  def renovation_apartments
    apartments.where(status: 'renovation').count
  end
end
