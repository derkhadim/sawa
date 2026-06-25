class Conversation < ApplicationRecord
  has_many :conversation_participants, dependent: :destroy
  has_many :participants, through: :conversation_participants, source: :user
  has_many :messages, dependent: :destroy

  def other_participant(user)
    participants.where.not(id: user.id).first
  end

  def last_message
    messages.order(created_at: :desc).first
  end

  def unread_count(user)
    cp = conversation_participants.find_by(user: user)
    return 0 unless cp
    messages.where.not(sender_id: user.id).where("created_at > ? OR read_at IS NULL", cp.last_read_at || Time.at(0)).where(read_at: nil).count
  end
end
