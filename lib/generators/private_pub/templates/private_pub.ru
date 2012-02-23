# Run with: rackup private_pub.ru -s thin -E production
require "bundler/setup"
require "yaml"
require "faye"
require "private_pub"

PrivatePub.load_config(File.expand_path("../config/private_pub.yml", __FILE__), ENV["RAILS_ENV"] || "development")

path = File.expand_path("../config/private_pub_redis.yml", __FILE__)
options = File.exist?(path) ? PrivatePub.load_redis_config(path, ENV['RAILS_ENV']) : {}

run PrivatePub.faye_app(options)
