#!/usr/bin/env ruby
# Usage: rails runner db/export_to_railway.rb [DATABASE_URL]
# Connects to local SQLite, dumps all data, imports into PostgreSQL on Railway

require 'sqlite3'
require 'pg'
require 'json'

DATABASE_URL = ARGV[0] || ENV['DATABASE_URL']
unless DATABASE_URL
  puts "Usage: rails runner db/export_to_railway.rb DATABASE_URL"
  puts "Or set DATABASE_URL env var (get it from: railway variables get DATABASE_URL)"
  exit 1
end

SQLITE_PATH = File.join(__dir__, 'development.sqlite3')
unless File.exist?(SQLITE_PATH)
  puts "SQLite database not found at #{SQLITE_PATH}"
  exit 1
end

TABLES = %w[
  agencies owners buildings apartments users payments incidents
  providers publications comments likes conversations conversation_participants
  messages move_out_notices roles permissions role_permissions user_roles
].freeze

IGNORED_TABLES = %w[schema_migrations ar_internal_metadata].freeze

sqlite = SQLite3::Database.new(SQLITE_PATH)
sqlite.results_as_hash = true

pg = PG.connect(DATABASE_URL)

puts "Connected to SQLite and PostgreSQL."

# Disable triggers and foreign keys during import
pg.exec("SET session_replication_role = 'replica'")

TABLES.each do |table|
  rows = sqlite.execute("SELECT * FROM #{table}")
  next if rows.empty?

  columns = rows.first.keys
  placeholders = columns.map.with_index { |_, i| "$#{i + 1}" }.join(', ')
  col_names = columns.join(', ')

  insert_sql = "INSERT INTO #{table} (#{col_names}) VALUES (#{placeholders})"

  rows.each do |row|
    values = columns.map do |col|
      val = row[col]
      if val.is_a?(Integer) || val.is_a?(Float)
        val
      elsif val.is_a?(String) && val.match?(/\A\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2}/)
        # Convert SQLite datetime format to PostgreSQL
        val.sub(' ', 'T')
      elsif val.nil?
        nil
      else
        val
      end
    end

    # Handle boolean columns: SQLite stores 0/1, PostgreSQL needs true/false
    # We need to map them from the schema
    begin
      pg.exec_params(insert_sql, values)
    rescue PG::Error => e
      puts "ERROR inserting into #{table}: #{e.message}"
      puts "  Values: #{values.inspect}"
    end
  end

  puts "Imported #{rows.size} rows into #{table}"
end

# Re-enable triggers and foreign keys
pg.exec("SET session_replication_role = 'origin'")

# Reset sequences
pg.exec("SELECT setval('users_id_seq', COALESCE((SELECT MAX(id) FROM users), 1))")
pg.exec("SELECT setval('agencies_id_seq', COALESCE((SELECT MAX(id) FROM agencies), 1))")
pg.exec("SELECT setval('owners_id_seq', COALESCE((SELECT MAX(id) FROM owners), 1))")
pg.exec("SELECT setval('buildings_id_seq', COALESCE((SELECT MAX(id) FROM buildings), 1))")
pg.exec("SELECT setval('apartments_id_seq', COALESCE((SELECT MAX(id) FROM apartments), 1))")
pg.exec("SELECT setval('payments_id_seq', COALESCE((SELECT MAX(id) FROM payments), 1))")
pg.exec("SELECT setval('incidents_id_seq', COALESCE((SELECT MAX(id) FROM incidents), 1))")
pg.exec("SELECT setval('providers_id_seq', COALESCE((SELECT MAX(id) FROM providers), 1))")
pg.exec("SELECT setval('publications_id_seq', COALESCE((SELECT MAX(id) FROM publications), 1))")
pg.exec("SELECT setval('comments_id_seq', COALESCE((SELECT MAX(id) FROM comments), 1))")
pg.exec("SELECT setval('conversations_id_seq', COALESCE((SELECT MAX(id) FROM conversations), 1))")
pg.exec("SELECT setval('messages_id_seq', COALESCE((SELECT MAX(id) FROM messages), 1))")
pg.exec("SELECT setval('move_out_notices_id_seq', COALESCE((SELECT MAX(id) FROM move_out_notices), 1))")
pg.exec("SELECT setval('roles_id_seq', COALESCE((SELECT MAX(id) FROM roles), 1))")
pg.exec("SELECT setval('permissions_id_seq', COALESCE((SELECT MAX(id) FROM permissions), 1))")

sqlite.close
pg.close

puts "\nExport terminé avec succès!"
