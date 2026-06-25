class Web::MessagesController < Web::ApplicationController
  def create
    @conversation = current_user.conversations.find(params[:conversation_id])
    body = params.dig(:message, :body) || params[:body]
    @message = @conversation.messages.create(sender: current_user, body: body)

    if @message.persisted?
      redirect_to conversations_path(selected_id: @conversation.id), notice: 'Message envoyé'
    else
      redirect_to conversations_path(selected_id: @conversation.id), alert: "Erreur lors de l'envoi"
    end
  end
end
