require 'private_pub/view_helpers'
require 'action_view'
require 'action_view/helpers'

include ActionController::RecordIdentifier    # dom_id
include ActionView::Helpers::RawOutputHelper  # capture
include ActionView::Helpers::TagHelper        # content_tag
include PrivatePub::ViewHelpers

module ActionController
  module RecordIdentifier
    def dom_id(object)
      [object.class.name.downcase, object.hash].join('_')
    end
  end
end

module ActionView
  module Helpers
    module CaptureHelper
      def capture(&block)
        yield
      end
    end
  end
end
