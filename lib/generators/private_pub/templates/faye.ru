# Run with: rackup faye.ru -s thin -E production
require "bundler/setup"
require "yaml"
require "faye"
require "private_pub"

PrivatePub.load_config(File.expand_path("../config/private_pub.yml", __FILE__), ENV["RAILS_ENV"] || "development")
run Faye::RackAdapter.new(:mount => "/faye", :timeout => 45, :extensions => [PrivatePub.faye_extension])
