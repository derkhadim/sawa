class Incident < ApplicationRecord
  belongs_to :apartment
  belongs_to :tenant, class_name: 'User'
  belongs_to :provider, optional: true

  validates :title, :description, presence: true
  validates :status, inclusion: { in: %w[open in_progress resolved] }

  scope :open, -> { where(status: 'open') }
  scope :in_progress, -> { where(status: 'in_progress') }

  def status_label
    case status
    when 'open' then 'Ouvert'
    when 'in_progress' then 'En cours'
    when 'resolved' then 'Réparé'
    else status
    end
  end
end
