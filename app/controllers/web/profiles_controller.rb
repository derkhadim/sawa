class Web::ProfilesController < Web::ApplicationController
  ALLOWED_EXTENSIONS = %w[jpg jpeg png gif webp].freeze

  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if params[:user][:profile_photo].present?
      uploaded = params[:user][:profile_photo]
      ext = safe_extension(uploaded.original_filename)
      filename = "profile_#{@user.id}_#{Time.now.to_i}.#{ext}"
      path = Rails.root.join('public', 'uploads', filename)
      File.open(path, 'wb') { |f| f.write(uploaded.read) }
      @user.profile_photo = "/uploads/#{filename}"
    end

    if params[:user][:cover_photo].present?
      uploaded = params[:user][:cover_photo]
      ext = safe_extension(uploaded.original_filename)
      filename = "cover_#{@user.id}_#{Time.now.to_i}.#{ext}"
      path = Rails.root.join('public', 'uploads', filename)
      File.open(path, 'wb') { |f| f.write(uploaded.read) }
      @user.cover_photo = "/uploads/#{filename}"
    end

    if @user.update(profile_params)
      redirect_to profile_path, notice: 'Profil mis à jour avec succès'
    else
      flash.now[:alert] = @user.errors.full_messages.join(', ')
      render :edit
    end
  end

  private

  def safe_extension(filename)
    ext = filename.split('.').last&.downcase
    return 'png' unless ext && ALLOWED_EXTENSIONS.include?(ext)
    ext
  end

  def profile_params
    params.require(:user).permit(:email, :phone, :first_name, :last_name, :password, :password_confirmation)
  end
end
