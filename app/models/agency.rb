class Agency < ApplicationRecord
  has_many :users
  has_many :owners
  has_many :buildings
  has_many :providers
  has_many :roles

  validates :name, presence: true
end
