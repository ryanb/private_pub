# Run with: rackup private_pub.ru -s thin -E production
require "bundler/setup"
require "yaml"
require "faye"
require "private_pub"

PrivatePub.load_config(File.expand_path("../config/private_pub.yml", __FILE__), ENV["RAILS_ENV"] || "development")

path = Rails.root.join("config/private_pub_redis.yml")
options = path.exist? ? PrivatePub.load_redis_config(path, Rails.env) : {}

run PrivatePub.faye_app(options)
