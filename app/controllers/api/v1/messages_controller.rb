module Api
  module V1
    class MessagesController < ApplicationController
      before_action :set_conversation

      def index
        messages = @conversation.messages.includes(:sender).order(created_at: :asc)
        @conversation.conversation_participants.where(user: current_user).update_all(last_read_at: Time.current)
        @conversation.messages.where.not(sender_id: current_user).update_all(read_at: Time.current)

        render json: { messages: messages.map { |m| message_json(m) } }
      end

      def create
        message = @conversation.messages.create(sender: current_user, body: params[:body])
        if message.persisted?
          render json: { message: message_json(message) }, status: :created
        else
          render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_conversation
        @conversation = current_user.conversations.find(params[:conversation_id])
      end

      def message_json(m)
        {
          id: m.id,
          body: m.body,
          sender_id: m.sender_id,
          sender_name: m.sender.full_name,
          created_at: m.created_at,
          read_at: m.read_at
        }
      end
    end
  end
end
