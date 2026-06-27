class Web::CommentsController < Web::ApplicationController
  include Authorization

  def create
    @publication = find_publication_in_scope

    unless current_user.tenant? || current_user.agence?
      redirect_back fallback_location: root_path, alert: 'Accès refusé'
      return
    end

    @comment = @publication.comments.new(comment_params.merge(user: current_user))

    if @comment.save
      redirect_back fallback_location: publication_path(@publication), notice: 'Commentaire ajouté'
    else
      redirect_back fallback_location: publication_path(@publication), alert: @comment.errors.full_messages.join(', ')
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
