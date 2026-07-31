class Agency < ApplicationRecord
  has_many :users
  has_many :buildings
  has_many :providers
  has_many :roles
  has_many :contracts

  validates :name, presence: true
end
