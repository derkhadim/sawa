module Api
  module V1
    class CommentsController < ApplicationController
      before_action :set_publication

      def index
        comments = @publication.comments.includes(:user).order(created_at: :desc)
        render json: {
          comments: comments.map do |c|
            {
              id: c.id,
              content: c.content,
              created_at: c.created_at,
              user: {
                id: c.user_id,
                name: c.user.full_name
              }
            }
          end
        }
      end

      def create
        unless current_user.tenant? || current_user.agence?
          return render json: { error: 'Accès refusé' }, status: :forbidden
        end

        comment = @publication.comments.new(
          user: current_user,
          content: params[:content]
        )

        if comment.save
          render json: {
            comment: {
              id: comment.id,
              content: comment.content,
              created_at: comment.created_at,
              user: {
                id: current_user.id,
                name: current_user.full_name
              }
            }
          }, status: :created
        else
          render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_publication
        @publication = find_publication_in_scope
      end
    end
  end
end
