web: bin/rails server -p $PORT -e $RAILS_ENV
worker: bundle exec sidekiq -e production -C config/sidekiq.yml
redis: redis-server --port 6379
