require "faye"
require "private_pub"
require File.expand_path("../config/initializers/private_pub.rb", __FILE__)

faye_server = Faye::RackAdapter.new(:mount => '/faye', :timeout => 45)
faye_server.add_extension(PrivatePub.faye_extension)
run faye_server
