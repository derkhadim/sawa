module Api
  module V1
    class PublicationsController < ApplicationController

      def index
        building = find_building_in_scope

        publications = building.publications.recent.includes(:tenant)
        render json: {
          publications: publications.map do |p|
            {
              id: p.id,
              content: p.content,
              created_at: p.created_at,
              likes_count: p.likes_count,
              comments_count: p.comments_count,
              liked_by_current_user: p.liked_by?(current_user),
              author: {
                id: p.tenant_id,
                name: "#{p.tenant.first_name} #{p.tenant.last_name}"
              }
            }
          end
        }
      end

      def create
        building = find_building_in_scope

        unless current_user.tenant? && current_user.tenant_buildings.ids.include?(building.id) ||
               current_user.agence? && current_user.agency.buildings.exists?(building.id)
          return render json: { error: 'Accès refusé' }, status: :forbidden
        end

        publication = building.publications.new(
          tenant: current_user,
          content: params[:content]
        )

        if publication.save
          render json: {
            publication: {
              id: publication.id,
              content: publication.content,
              created_at: publication.created_at,
              author: {
                id: current_user.id,
                name: "#{current_user.first_name} #{current_user.last_name}"
              }
            }
          }, status: :created
        else
          render json: { errors: publication.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def show
        publication = find_publication_in_scope

        comments = publication.comments.includes(:user).order(created_at: :desc)

        render json: {
          publication: {
            id: publication.id,
            content: publication.content,
            created_at: publication.created_at,
            building_id: publication.building_id,
            building_name: publication.building.name,
            author: {
              id: publication.tenant_id,
              name: publication.tenant.full_name
            },
            likes_count: publication.likes_count,
            liked_by_current_user: publication.liked_by?(current_user),
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
        }
      end

      def like
        publication = find_publication_in_scope

        unless current_user.tenant? || current_user.agence?
          return render json: { error: 'Accès refusé' }, status: :forbidden
        end

        like = publication.likes.find_by(user: current_user)

        if like
          like.destroy
          render json: { liked: false, likes_count: publication.likes_count }
        else
          publication.likes.create!(user: current_user)
          render json: { liked: true, likes_count: publication.likes_count }
        end
      end

      def agent_feed
        return render json: { error: 'Accès refusé' }, status: :forbidden unless current_user.agence?

        agency = current_user.agency
        building_ids = agency.buildings.pluck(:id)
        publications = Publication.where(building_id: building_ids).recent.includes(:tenant, :building)

        render json: {
          publications: publications.map do |p|
            {
              id: p.id,
              content: p.content,
              created_at: p.created_at,
              building_id: p.building_id,
              building_name: p.building.name,
              author: {
                id: p.tenant_id,
                name: p.tenant.full_name
              },
              likes_count: p.likes_count,
              liked_by_current_user: p.liked_by?(current_user)
            }
          end
        }
      end

      def owner_feed
        return render json: { error: 'Accès refusé' }, status: :forbidden unless current_user.owner?

        owner = current_owner
        return render json: { publications: [] } unless owner

        building_ids = owner.buildings.pluck(:id)
        publications = Publication.where(building_id: building_ids).recent.includes(:tenant, :building)

        render json: {
          publications: publications.map do |p|
            {
              id: p.id,
              content: p.content,
              created_at: p.created_at,
              building_id: p.building_id,
              building_name: p.building.name,
              author: {
                id: p.tenant_id,
                name: p.tenant.full_name
              },
              likes_count: p.likes_count,
              liked_by_current_user: p.liked_by?(current_user)
            }
          end
        }
      end
    end
  end
end
