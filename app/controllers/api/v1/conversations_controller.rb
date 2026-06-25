module Api
  module V1
    class ConversationsController < ApplicationController
      def index
        conversations = current_user.conversations
          .includes(:participants, :messages)
          .order(updated_at: :desc)
        render json: { conversations: conversations.map { |c| conversation_json(c) } }
      end

      def create
        other = User.find(params[:user_id])
        existing = current_user.conversations.joins(:conversation_participants)
          .where(conversation_participants: { user_id: other.id })
          .first

        if existing
          if params[:message].present?
            existing.messages.create(sender: current_user, body: params[:message])
          end
          render json: { conversation: conversation_json(existing) }
          return
        end

        conversation = Conversation.create!
        conversation.conversation_participants.create!(user: current_user)
        conversation.conversation_participants.create!(user: other)

        if params[:message].present?
          conversation.messages.create!(sender: current_user, body: params[:message])
        end

        render json: { conversation: conversation_json(conversation) }, status: :created
      end

      def show
        conversation = current_user.conversations.find(params[:id])
        render json: { conversation: conversation_json(conversation) }
      end

      private

      def conversation_json(c)
        other = c.other_participant(current_user)
        lm = c.last_message
        {
          id: c.id,
          other_user: other ? { id: other.id, name: other.full_name, role: other.role } : nil,
          last_message: lm ? { body: lm.body.truncate(80), created_at: lm.created_at, sender_id: lm.sender_id } : nil,
          unread_count: c.unread_count(current_user),
          updated_at: c.updated_at
        }
      end
    end
  end
end
