class Publication < ApplicationRecord
  belongs_to :building
  belongs_to :tenant, class_name: 'User'

  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :content, presence: true

  scope :recent, -> { order(created_at: :desc) }

  def liked_by?(user)
    likes.exists?(user: user)
  end
end
