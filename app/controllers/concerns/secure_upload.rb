module SecureUpload
  ALLOWED_EXTENSIONS = %w[jpg jpeg png gif webp].freeze
  MAX_FILE_SIZE = 10.megabytes

  class UploadError < StandardError; end

  def safe_extension(filename)
    ext = File.extname(filename).delete('.').downcase
    return 'png' unless ext.present? && ALLOWED_EXTENSIONS.include?(ext)
    ext
  end

  # Valide un upload (taille + magic bytes) et retourne l'extension
  # réellement détectée dans le contenu. Soulève UploadError en cas de problème.
  def validate_upload!(file, allowed: ALLOWED_EXTENSIONS)
    unless file.respond_to?(:read) && file.respond_to?(:rewind) && file.respond_to?(:size)
      raise UploadError, 'Fichier invalide'
    end

    if file.size.to_i > MAX_FILE_SIZE
      raise UploadError, "Le fichier ne doit pas dépasser #{MAX_FILE_SIZE / 1.megabyte} Mo"
    end

    detected = magic_extension(file)
    unless detected && allowed.include?(detected)
      raise UploadError, 'Type de fichier non autorisé'
    end

    detected
  ensure
    file.rewind if file.respond_to?(:rewind)
  end

  private

  def magic_extension(file)
    file.rewind
    head = file.read(12).to_s.b
    file.rewind

    case head
    when /\A\x89PNG\r\n\x1a\n/n then 'png'
    when /\A\xFF\xD8\xFF/n         then 'jpg'
    when /\AGIF87a/n, /\AGIF89a/n  then 'gif'
    when /\ARIFF/n                  then head[8, 4] == 'WEBP' ? 'webp' : nil
    end
  end
end
