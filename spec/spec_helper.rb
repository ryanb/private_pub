require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

RSpec.configure do |config|
  config.mock_with :rspec
end
