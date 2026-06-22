class Comment < ApplicationRecord
  belongs_to :publication, counter_cache: true
  belongs_to :user

  validates :content, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
