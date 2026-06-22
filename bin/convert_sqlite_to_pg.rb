#!/usr/bin/env ruby
sqlite_path = File.join(__dir__, '..', 'db', 'export.sql')
pg_path = File.join(__dir__, '..', 'db', 'import.sql')

content = File.read(sqlite_path)

# Remove SQLite pragmas
content.gsub!(/^PRAGMA.*$/, '')
content.gsub!(/^BEGIN TRANSACTION;/, 'BEGIN;')

# Remove inline foreign key constraints (Rails schema.rb handles these)
content.gsub!(/,\s*CONSTRAINT "[^"]+"\s*FOREIGN KEY\s*\([^)]+\)\s*REFERENCES\s*"[^"]+"\s*\([^)]+\)/, '')

# Convert CREATE TABLE: integer PRIMARY KEY AUTOINCREMENT NOT NULL -> bigserial PRIMARY KEY
content.gsub!(/"id"\s+integer\s+PRIMARY\s+KEY\s+AUTOINCREMENT\s+NOT\s+NULL/, '"id" bigserial PRIMARY KEY')

# Convert datetime(6) -> timestamp(6)
content.gsub!(/datetime\(6\)/, 'timestamp(6)')

# Convert boolean DEFAULT 0 -> boolean DEFAULT false
content.gsub!(/boolean\s+DEFAULT\s+0/, 'boolean DEFAULT false')

# Convert boolean DEFAULT 1 -> boolean DEFAULT true
content.gsub!(/boolean\s+DEFAULT\s+1/, 'boolean DEFAULT true')

# Remove trailing commas before ) in CREATE TABLE
content.gsub!(/,\s*\)/, ')')

# Replace SQLite hex literals X'...' with PostgreSQL hex format
content.gsub!(/X'([0-9a-fA-F]+)'/, "'\\\\x\\1'")

File.write(pg_path, content)
puts "Converted to #{pg_path}"
