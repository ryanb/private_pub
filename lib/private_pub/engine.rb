require "private_pub/view_helpers"

module PrivatePub
  class Engine < Rails::Engine
    # Adds the ViewHelpers into ActionView::Base
    initializer "private_pub.view_helpers" do
      ActionView::Base.send :include, ViewHelpers
    end
  end
end
