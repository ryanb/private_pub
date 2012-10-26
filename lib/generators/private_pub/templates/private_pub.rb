# Use this setup block to configure all options available in PrivatePub.
PrivatePub.setup do |private_pub|
  private_pub.config['server'] = 'http://localhost:9292/faye'
  private_pub.config['secret_token'] = '<%= defined?(SecureRandom) ? SecureRandom.hex(32) : ActiveSupport::SecureRandom.hex(32) %>'
  private_pub.config['signature_expiration'] = 3600 # one hour
end