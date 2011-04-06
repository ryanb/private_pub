begin
  require "faye"
  require "private_pub"
rescue LoadError
  require "bundler/setup"
  require "faye"
  require "private_pub"
end

PrivatePub.load_config "config/private_pub.yml", ENV["RAILS_ENV"] || "development"
faye_server = Faye::RackAdapter.new(:mount => '/faye', :timeout => 45)
faye_server.add_extension(PrivatePub.faye_extension)
run faye_server
