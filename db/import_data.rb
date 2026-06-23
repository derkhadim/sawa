#!/usr/bin/env ruby
# bundle exec rails runner db/import_data.rb RAILS_ENV=production

sql = File.read(File.join(__dir__, 'import.sql'))

lines = sql.split("\n")
fixed = lines.map do |line|
  if line.start_with?("INSERT INTO apartments ")
    # Fix boolean visible column: 0/1 -> false/true
    line.sub(/,(0|1)\);$/) { |m| m.sub('0', 'false').sub('1', 'true') }
  else
    line
  end
end
sql = fixed.join("\n")

# Remove BEGIN/COMMIT since execute handles transactions
sql.sub!(/\ABEGIN;\s*/, '')
sql.sub!(/;\s*COMMIT;\s*\z/, '')
sql.strip!

conn = ActiveRecord::Base.connection.raw_connection
conn.exec(sql)
puts "Import terminé."
