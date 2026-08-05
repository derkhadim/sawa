web: bundle exec puma -C config/puma.rb
release: script -c "for i in 1 2 3 4 5; do bundle exec rails db:prepare && break; echo 'DB not ready, retry $i'; sleep 5; done"
