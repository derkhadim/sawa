module Api
  module V1
    class AuthController < ApplicationController
      include SecureUpload
      skip_before_action :authenticate_request, only: [:register, :login, :forgot_password, :reset_password]

      def register
        user = User.new(user_params)
        user.role = 'tenant'

        if user.save
          token = JwtService.encode(user_id: user.id, role: user.role, jwt_version: user.jwt_version)
          render json: { user: user_response(user), token: token }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def login
        user = User.find_by(phone: params[:phone])

        if user&.authenticate(params[:password])
          login_role = params[:login_role] || user.role

          unless role_available?(user, login_role)
            return render json: { error: "Ce rôle n'est pas disponible pour ce compte" }, status: :forbidden
          end

          # Le rôle embarqué dans le JWT est la vérité serveur (rôle en base).
          # login_role ne sert qu'à l'interface (sélection d'écran), il n'est
          # jamais utilisé pour autoriser une action.
          token = JwtService.encode(user_id: user.id, role: user.role, jwt_version: user.jwt_version)
          render json: { user: user_response(user, login_role), token: token }
        else
          render json: { error: 'Téléphone ou mot de passe invalide' }, status: :unauthorized
        end
      end

      def me
        render json: { user: user_response(current_user) }
      end

      def logout
        current_user.revoke_jwt!
        render json: { message: 'Déconnecté' }
      end

      def forgot_password
        phone = params[:phone].to_s
        user = User.find_by(phone: phone)

        # Pas de mailer/SMS : on renvoie le token dans la réponse pour un
        # canal hors-bande (l'agence le communique au locataire). À remplacer
        # par un vrai canal (SMS/email) si des providers sont ajoutés.
        if user
          token = user.generate_reset_token!
          return render json: { message: 'Code de réinitialisation généré', reset_token: token }
        end

        # Même réponse qu'un succès pour ne pas révéler l'existence du compte.
        render json: { message: 'Si ce numéro existe, un code a été généré', reset_token: nil }
      end

      def reset_password
        user = User.find_by(phone: params[:phone].to_s)
        token = params[:reset_token].to_s
        password = params[:password].to_s

        unless user && user.reset_token_valid?(token)
          return render json: { error: 'Code invalide ou expiré' }, status: :unprocessable_entity
        end

        if password.length < 8
          return render json: { error: 'Le mot de passe doit contenir au moins 8 caractères' }, status: :unprocessable_entity
        end

        user.password = password
        if user.save
          user.consume_reset_token!
          token = JwtService.encode(user_id: user.id, role: user.role, jwt_version: user.jwt_version)
          render json: { message: 'Mot de passe réinitialisé', user: user_response(user), token: token }
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update_profile
        user = current_user

        begin
          if params[:profile_photo].present?
            uploaded = params[:profile_photo]
            ext = validate_upload!(uploaded)
            filename = "profile_#{user.id}_#{Time.now.to_i}.#{ext}"
            path = Rails.root.join('public', 'uploads', filename)
            File.open(path, 'wb') { |f| f.write(uploaded.read) }
            user.profile_photo = "/uploads/#{filename}"
          end

          if params[:cover_photo].present?
            uploaded = params[:cover_photo]
            ext = validate_upload!(uploaded)
            filename = "cover_#{user.id}_#{Time.now.to_i}.#{ext}"
            path = Rails.root.join('public', 'uploads', filename)
            File.open(path, 'wb') { |f| f.write(uploaded.read) }
            user.cover_photo = "/uploads/#{filename}"
          end
        rescue SecureUpload::UploadError => e
          return render json: { errors: [e.message] }, status: :unprocessable_entity
        end

        if user.update(profile_params)
          render json: { user: user_response(user) }
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.permit(:phone, :password, :password_confirmation, :first_name, :last_name)
      end

      def profile_params
        params.permit(:email, :phone, :first_name, :last_name)
      end

      def user_response(user, effective_role = nil)
        {
          id: user.id,
          email: user.email,
          phone: user.phone,
          first_name: user.first_name,
          last_name: user.last_name,
          role: effective_role || user.role,
          agency_id: user.agency_id,
          building_id: user.building_id,
          profile_photo: user.profile_photo,
          cover_photo: user.cover_photo,
          owner_id: user.owner_id
        }
      end

      PUBLIC_ROLES = %w[tenant owner agence super_admin].freeze

      def role_available?(user, login_role)
        return false unless PUBLIC_ROLES.include?(login_role)

        case login_role
        when 'owner' then user.role == 'owner' || user.owner.present?
        when 'tenant' then user.role == 'tenant' || user.building_id.present?
        else user.role == login_role
        end
      end
    end
  end
end
