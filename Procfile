web: bundle exec puma -C config/puma.rb
release: bundle exec rails db:prepare || (echo 'DB not ready, retrying...' && sleep 10 && bundle exec rails db:prepare)
