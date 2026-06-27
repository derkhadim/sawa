class Web::ConversationsController < Web::ApplicationController
  def index
    @conversations = current_user.conversations
      .includes(:participants)
      .order(updated_at: :desc)

    if params[:selected_id].present?
      @selected = current_user.conversations.find_by(id: params[:selected_id])
      if @selected
        @messages = @selected.messages.includes(:sender).order(created_at: :asc)
        @selected.conversation_participants.where(user: current_user).update_all(last_read_at: Time.current)
        @selected.messages.where.not(sender_id: current_user).update_all(read_at: Time.current)
        @other = @selected.other_participant(current_user)
      end
    end
  end

  def create
    other = find_messagable_user
    unless other
      redirect_to conversations_path, alert: 'Utilisateur introuvable'
      return
    end
    existing = current_user.conversations.joins(:conversation_participants)
      .where(conversation_participants: { user_id: other.id })
      .first

    if existing
      if params[:message].present?
        existing.messages.create!(sender: current_user, body: params[:message])
      end
      redirect_to conversations_path(selected_id: existing.id)
      return
    end

    conversation = Conversation.create!
    conversation.conversation_participants.create!(user: current_user)
    conversation.conversation_participants.create!(user: other)

    if params[:message].present?
      conversation.messages.create!(sender: current_user, body: params[:message])
    end

    redirect_to conversations_path(selected_id: conversation.id)
  end

  private

  def find_messagable_user
    if current_user.agence?
      User.where(agency_id: current_user.agency_id).find_by(id: params[:user_id])
    elsif current_user.tenant?
      agency_ids = current_user.tenant_buildings.pluck(:agency_id).compact.uniq
      User.where(agency_id: agency_ids, role: 'agence').find_by(id: params[:user_id])
    else
      nil
    end
  end
end