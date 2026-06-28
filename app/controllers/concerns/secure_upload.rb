module SecureUpload
  ALLOWED_EXTENSIONS = %w[jpg jpeg png gif webp].freeze
  MAX_FILE_SIZE = 10.megabytes

  def safe_extension(filename)
    ext = File.extname(filename).delete('.').downcase
    return 'png' unless ext.present? && ALLOWED_EXTENSIONS.include?(ext)
    ext
  end

  def validate_file_size(file)
    if file.respond_to?(:size) && file.size > MAX_FILE_SIZE
      file.errors.add(:base, "Le fichier ne doit pas dépasser 10 Mo")
      return false
    end
    true
  end
end
