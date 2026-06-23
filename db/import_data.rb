#!/usr/bin/env ruby
# bundle exec rails runner db/import_data.rb RAILS_ENV=production

sql = File.read(File.join(__dir__, 'import.sql'))
# Remove BEGIN/COMMIT since execute handles transactions
sql.sub!(/\ABEGIN;\s*/, '')
sql.sub!(/;\s*COMMIT;\s*\z/, '')
sql.strip!

conn = ActiveRecord::Base.connection.raw_connection
conn.exec(sql)
puts "Import terminé."
