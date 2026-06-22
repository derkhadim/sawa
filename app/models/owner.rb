class Owner < ApplicationRecord
  belongs_to :agency
  has_many :buildings

  validates :first_name, :last_name, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end
end
