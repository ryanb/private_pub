# Use this setup block to configure all options available in PrivatePub.
PrivatePub.setup do |private_pub|
  # By default, all configuration is loaded from config/private_pub.yml.
  # Be sure to also change your private_pub.ru file if you modify this behavior.
  path = Rails.root.join("config/private_pub.yml")
  PrivatePub.load_config(path, Rails.env) if path.exist?
end