require 'sidekiq'

Sidekiq.configure_client do |config|
  config.redis = { size: 2, url: 'redis://127.0.0.1:6379/0' }
end

Sidekiq.configure_server do |config|
  config.redis = { size: 6, url: 'redis://127.0.0.1:6379/0' }
end
