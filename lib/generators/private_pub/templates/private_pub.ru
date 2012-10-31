# Run with: rackup private_pub.ru -s thin -E production
require "bundler/setup"
require "yaml"
require "faye"
require "private_pub"
require "thin"

Faye::WebSocket.load_adapter('thin')

PrivatePub.load_config(File.expand_path("../config/private_pub.yml", __FILE__), ENV["RAILS_ENV"] || "development")
Faye::WebSocket.load_adapter(PrivatePub.config[:adapter])

path = File.expand_path("../config/private_pub_redis.yml", __FILE__)
options = {}
if File.exist?(path)
  require 'faye/redis'
  options.merge(PrivatePub.load_redis_config(path, ENV['RAILS_ENV'] || 'development'))
end

run PrivatePub.faye_app(options)
