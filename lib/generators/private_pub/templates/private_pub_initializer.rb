private_pub_config = YAML.load_file("#{Rails.root.to_s}/config/private_pub.yml")[Rails.env]
PrivatePub.server = private_pub_config["server"]
PrivatePub.secret_token = private_pub_config["secret_token"]
