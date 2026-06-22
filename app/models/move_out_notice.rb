class MoveOutNotice < ApplicationRecord
  belongs_to :apartment
  belongs_to :tenant, class_name: 'User'

  validates :move_out_date, presence: true
  validate :move_out_date_must_be_future

  private

  def move_out_date_must_be_future
    if move_out_date.present? && move_out_date <= Date.today
      errors.add(:move_out_date, 'doit être dans le futur')
    end
  end
end
