class Like < ApplicationRecord
  belongs_to :publication, counter_cache: true
  belongs_to :user

  validates :user_id, uniqueness: { scope: :publication_id }
end
