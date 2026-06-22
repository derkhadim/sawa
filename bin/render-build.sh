#!/usr/bin/env bash
set -e

cd web

# Install Ruby dependencies
bundle install --jobs 4 --retry 3

# Precompile assets
bundle exec rake assets:precompile

# Run migrations
bundle exec rake db:migrate
