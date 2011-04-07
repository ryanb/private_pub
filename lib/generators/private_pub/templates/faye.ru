# Run with: rackup faye.ru -s thin -E production
require "yaml"
require "faye"
begin
  require "private_pub"
rescue LoadError
  require "bundler/setup"
  require "private_pub"
end

PrivatePub.load_config(File.expand_path("../config/private_pub.yml", __FILE__), ENV["RAILS_ENV"] || "development")
run Faye::RackAdapter.new(:mount => "/faye", :timeout => 45, :extensions => [PrivatePub.faye_extension])
