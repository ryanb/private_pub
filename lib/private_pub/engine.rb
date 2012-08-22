require "private_pub/view_helpers"

module PrivatePub
  class Engine < Rails::Engine
    # Loads the private_pub.yml file if it exists.
    initializer "private_pub.config" do
      path = Rails.root.join("config/private_pub.yml")
      PrivatePub.load_config(path, Rails.env) if path.exist?
    end

    # Adds the ViewHelpers into ActionView::Base
    initializer "private_pub.view_helpers" do
      ActionView::Base.send :include, ViewHelpers
    end
  end
end
