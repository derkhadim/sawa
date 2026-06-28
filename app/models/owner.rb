class Owner < ApplicationRecord
  has_many :buildings
  has_many :users

  validates :first_name, :last_name, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end
end
