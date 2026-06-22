namespace :ratings do
  desc "Recalculer la note de tous les locataires"
  task compute: :environment do
    User.where(role: 'tenant').find_each do |u|
      old = u.rating
      u.compute_rating!
      if u.rating != old
        puts "#{u.full_name}: #{old} → #{u.rating} (#{u.rating_label})"
      end
    end
    puts "Terminé."
  end
end
