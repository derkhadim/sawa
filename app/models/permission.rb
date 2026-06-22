class Permission < ApplicationRecord
  has_many :role_permissions, dependent: :destroy
  has_many :roles, through: :role_permissions

  validates :resource, :action, presence: true
  validates :action, uniqueness: { scope: :resource }

  def name
    "#{resource}##{action}"
  end
end
