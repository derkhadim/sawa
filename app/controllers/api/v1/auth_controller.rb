module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_request, only: [:register, :login]

      def register
        user = User.new(user_params)
        user.role = params[:role] || 'tenant'

        if user.role == 'agence'
          agency_name = params[:agency_name]
          unless agency_name.present?
            return render json: { errors: ["Le nom de l'agence est requis"] }, status: :unprocessable_entity
          end
          user.agency = Agency.create!(name: agency_name)
        end

        if user.save
          token = JwtService.encode(user_id: user.id, role: user.role)
          render json: { user: user_response(user), token: token }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def login
        user = User.find_by(email: params[:email])

        if user&.authenticate(params[:password])
          token = JwtService.encode(user_id: user.id, role: user.role)
          render json: { user: user_response(user), token: token }
        else
          render json: { error: 'Email ou mot de passe invalide' }, status: :unauthorized
        end
      end

      def me
        render json: { user: user_response(current_user) }
      end

      ALLOWED_EXTENSIONS = %w[jpg jpeg png gif webp].freeze

      def update_profile
        user = current_user

        if params[:profile_photo].present?
          uploaded = params[:profile_photo]
          ext = safe_extension(uploaded.original_filename)
          filename = "profile_#{user.id}_#{Time.now.to_i}.#{ext}"
          path = Rails.root.join('public', 'uploads', filename)
          File.open(path, 'wb') { |f| f.write(uploaded.read) }
          user.profile_photo = "/uploads/#{filename}"
        end

        if params[:cover_photo].present?
          uploaded = params[:cover_photo]
          ext = safe_extension(uploaded.original_filename)
          filename = "cover_#{user.id}_#{Time.now.to_i}.#{ext}"
          path = Rails.root.join('public', 'uploads', filename)
          File.open(path, 'wb') { |f| f.write(uploaded.read) }
          user.cover_photo = "/uploads/#{filename}"
        end

        if user.update(profile_params)
          render json: { user: user_response(user) }
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.permit(:email, :phone, :password, :password_confirmation, :first_name, :last_name)
      end

      def profile_params
        params.permit(:email, :phone, :first_name, :last_name, :profile_photo, :cover_photo)
      end

      def safe_extension(filename)
        ext = filename.split('.').last&.downcase
        return 'png' unless ext && ALLOWED_EXTENSIONS.include?(ext)
        ext
      end

      def user_response(user)
        {
          id: user.id,
          email: user.email,
          phone: user.phone,
          first_name: user.first_name,
          last_name: user.last_name,
          role: user.role,
          agency_id: user.agency_id,
          building_id: user.building_id,
          profile_photo: user.profile_photo,
          cover_photo: user.cover_photo
        }
      end
    end
  end
end
